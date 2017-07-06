class Stock < ActiveRecord::Base
  include SearchCop

  # has_many :insider_transactions
  has_many :insider_transactions, foreign_key: :stock_symbol, primary_key: :symbol

  validate :force_symbol_uppercase
  validates :symbol, presence: true, allow_blank: false, uniqueness: true


  EDGAR_OFFSET_INTERVAL = 25
  EDGAR_SLEEP_INTERVAL = 0.65

  search_scope :search do
    attributes :symbol
  end

  alias_attribute :year_low, :low_52_weeks
  alias_attribute :year_high, :high_52_weeks
  alias_attribute :stock_price, :last_trade_price


  def self.all_yahoo_fields
    [:after_hours_change_real_time,:annualized_gain,:ask,:ask_real_time,:ask_size,:average_daily_volume,:bid,:bid_real_time,:bid_size,:book_value,:change,:change_percent_change,:change_from_200_day_moving_average,:change_from_50_day_moving_average,:change_from_52_week_high,:change_From_52_week_low,:change_in_percent,:change_percent_realtime,:change_real_time,:close,:comission,:day_value_change,:day_value_change_realtime,:days_range,:days_range_realtime,:dividend_pay_date,:dividend_per_share,:dividend_yield,:earnings_per_share,:ebitda,:eps_estimate_current_year,:eps_estimate_next_quarter,:eps_estimate_next_year,:error_indicator,:ex_dividend_date,:float_shares,:high,:high_52_weeks,:high_limit,:holdings_gain,:holdings_gain_percent,:holdings_gain_percent_realtime,:holdings_gain_realtime,:holdings_value,:holdings_value_realtime,:last_trade_date,:last_trade_price,:last_trade_realtime_withtime,:last_trade_size,:last_trade_time,:last_trade_with_time,:low,:low_52_weeks,:low_limit,:market_cap_realtime,:market_capitalization,:more_info,:moving_average_200_day,:moving_average_50_day,:name,:notes,:one_year_target_price,:open,:order_book,:pe_ratio,:pe_ratio_realtime,:peg_ratio,:percent_change_from_200_day_moving_average,:percent_change_from_50_day_moving_average,:percent_change_from_52_week_high,:percent_change_from_52_week_low,:previous_close,:price_eps_estimate_current_year,:price_eps_Estimate_next_year,:price_paid,:price_per_book,:price_per_sales,:revenue,:shares_outstanding,:shares_owned,:short_ratio,:stock_exchange,:symbol,:ticker_trend,:trade_date,:trade_links,:volume,:weeks_range_52]
  end

  def self.fetch_all_stock_names
    res = Faraday.get("https://www.quandl.com/api/v3/datatables/WIKI/PRICES.json?date=2017-6-30&api_key=#{ENV["ST_QUANDL_API_KEY"]}")
    body = JSON.parse(res.body)

    stocks = body["datatable"]["data"]

    stock_names = stocks.map {|s| s[0]}

    stock_names
  end

  def self.update_stocks
    Stock.create_stocks
  end

  def self.create_stocks
    Stock.destroy_all

    new_stocks = []

    stock_names = Stock.fetch_all_stock_names

    # stock_names.in_groups_of(99) do |curr_stock_names|
    #   quotes = StockQuote::Stock.quote(curr_stock_names.compact)
    #   new_stocks.concat Stock.create_stocks_with_quotes(quotes, false)
    # end

    yahoo_client = YahooFinance::Client.new
    quotes = yahoo_client.quotes(stock_names, Stock.all_yahoo_fields, { na_as_nil: true })
    new_stocks = Stock.create_stocks_with_quotes(quotes, save: false)

    status = Stock.import Stock.column_names, new_stocks

    "Imported #{status.ids.length} stocks, failed to import #{status.failed_instances.length}"
  end

  def update_stock
    quote = StockQuote::Stock.quote(self.symbol)
    self.update_stock_with_quote(quote)
  end

  def insider_volume
    self.insider_transactions.sum(:net_shares)
  end

  def insider_avg_price
    self.insider_transactions.average(:transaction_price_from)
  end

  def near_to_52_weeks
    return "" if self.year_high.blank? || self.stock_price.blank? || self.year_low.blank?

    high_diff = (self.year_high - self.stock_price).abs
    low_diff = (self.year_low - self.stock_price).abs
    modifier = 0.5

    if high_diff < low_diff * modifier
      percentage = (high_diff / self.stock_price * 100).to_i
      "#{percentage}% from high"
    elsif low_diff < high_diff * modifier
      percentage = (low_diff / self.stock_price * 100).to_i
      "#{percentage}% from low"
    else
      "Between high and low"
    end
  end

  def self.create_stocks_with_quotes(quotes, save: true)
    stocks = []
    quotes.each do |quote|
      stocks << Stock.create_stock_with_quote(quote, save)
    end

    stocks
  end

  def self.create_stock_with_quote(quote, save=true)
    stock = Stock.new({})
    stock.update_stock_with_quote(quote)

    if save
      stock.save
    else
      stock
    end
  end

  def self.update_insider_data
    InsiderTransaction.destroy_all

    date_strs = Date.date_strings_in_past_days 30
    # date_strs = ["20170622"]
    issue_ids = {}
    dates_to_issue_ids = {}
    round = 0

    date_strs.each do |str|
      ["sharessold", "sharesbought"].each do |filter|
        offset = 0
        keep_going = true
        num_rows = nil

        while keep_going
          puts "Stock update_insider_data: Processing offset #{offset} for round #{round}"

          url = "http://edgaronline.api.mashery.com/v2/insiders/summary.json?appkey=#{ENV["ST_EDGAR_API_KEY"]}&offset=#{offset}&transactiondates=#{str}&filter=#{filter} gt 0"
          res = Faraday.get url
          data = JSON.parse(res.body)

          if data.blank? || data["result"].blank?
            puts data
            return
          else
            transactions = data["result"]["rows"]

            if num_rows.nil?
              puts data["result"]["totalrows"].to_i
            end

            num_rows = data["result"]["totalrows"].to_i

            transactions.each do |transaction|
              next if transaction.blank?

              new_transaction_data = InsiderTransaction.data_with_transaction(transaction)

              issue_id = new_transaction_data[:issue_id]

              if new_transaction_data[:transaction_date]
                date_str = new_transaction_data[:transaction_date].strftime("%Y%m%d")

                dates_to_issue_ids[date_str] = [] if dates_to_issue_ids[date_str].blank?
                dates_to_issue_ids[date_str] << issue_id
              end

              issue_ids[issue_id] = {transactions: []} if issue_ids[issue_id].blank?
              issue_ids[issue_id][:transactions] << new_transaction_data
            end

            round += 1
            # if round % 2 == 0
              sleep EDGAR_SLEEP_INTERVAL
            # end

            if offset + EDGAR_OFFSET_INTERVAL < num_rows
              offset += EDGAR_OFFSET_INTERVAL
              keep_going = true
            else
              keep_going = false
            end

          end
        end
      end
    end

    puts dates_to_issue_ids

    issue_ids_to_stock_ids = InsiderTransaction.stock_ids_for_dates_issue_ids(dates_to_issue_ids)
    return if issue_ids_to_stock_ids.nil? #errored

    new_transactions = []
    #get issue ids and match to stock names
    issue_ids.each do |issue_id, issue_id_data|
      transactions = issue_id_data[:transactions]

      ticker = issue_ids_to_stock_ids[issue_id.to_s]

      if !ticker.blank?
        transactions.each do |t_data|
          t_data[:stock_symbol] = ticker
          new_transactions << InsiderTransaction.new(t_data)
        end
      end
    end

    puts "Made #{round} API calls to edgar in Stock.update_insider_data"
    status = InsiderTransaction.import InsiderTransaction.column_names, new_transactions

    "Imported #{status.ids.length} transactions, failed to import #{status.failed_instances.length}"
  end

  def update_stock_with_quote(quote)
    Stock.all_yahoo_fields.each do |field_sym|
      field = field_sym.to_s

      if field == "open" #fix bug with send() not recognizing field as arg
        self.open = quote.open
        next
      end

      if self.respond_to?(field.downcase) && quote.respond_to?(field)
        begin
          val = quote.send(field)
          next if val.nil?

          if field.include? "date"
            parsed_date = Date.parse_with_slashes val

            if parsed_date
              val = parsed_date
            end
          end

          self.send("#{field.downcase}=", val)
        rescue => e
          puts e
        end
      end
    end

    # self.after_hours_change_real_time = quote.after_hours_change_real_time
    # self.annualized_gain = quote.annualized_gain
    # self.ask = quote.ask
    # self.ask_real_time = quote.ask_real_time
    # self.ask_size = quote.ask_size
    # self.average_daily_volume = quote.average_daily_volume
    # self.bid = quote.bid
    # self.bid_real_time = quote.bid_real_time
    # self.bid_size = quote.bid_size
    # self.book_value = quote.book_value
    # self.change = quote.change
    # self.change_and_percent_change = quote.change_and_percent_change
    # self.change_from_200_day_moving_average = quote.change_from_200_day_moving_average
    # self.change_from_50_day_moving_average = quote.change_from_50_day_moving_average
    # self.change_from_52_week_high = quote.change_from_52_week_high
    # self.change_From_52_week_low = quote.change_From_52_week_low
    # self.change_in_percent = quote.change_in_percent
    # self.change_percent_realtime = quote.change_percent_realtime
    # self.change_real_time = quote.change_real_time
    # self.close = quote.close
    # self.comission = quote.comission
    # self.day_value_change = quote.day_value_change
    # self.day_value_change_realtime = quote.day_value_change_realtime
    # self.days_range = quote.days_range
    # self.days_range_realtime = quote.days_range_realtime
    # self.dividend_pay_date = quote.dividend_pay_date
    # self.dividend_per_share = quote.dividend_per_share
    # self.dividend_yield = quote.dividend_yield
    # self.earnings_per_share = quote.earnings_per_share
    # self.ebitda = quote.ebitda
    # self.eps_estimate_current_year = quote.eps_estimate_current_year
    # self.eps_estimate_next_quarter = quote.eps_estimate_next_quarter
    # self.eps_estimate_next_year = quote.eps_estimate_next_year
    # self.error_indicator = quote.error_indicator
    # self.ex_dividend_date = quote.ex_dividend_date
    # self.float_shares = quote.float_shares
    # self.high = quote.high
    # self.high_52_weeks = quote.high_52_weeks
    # self.high_limit = quote.high_limit
    # self.holdings_gain = quote.holdings_gain
    # self.holdings_gain_percent = quote.holdings_gain_percent
    # self.holdings_gain_percent_realtime = quote.holdings_gain_percent_realtime
    # self.holdings_gain_realtime = quote.holdings_gain_realtime
    # self.holdings_value = quote.holdings_value
    # self.holdings_value_realtime = quote.holdings_value_realtime
    # self.last_trade_date = Date.parse_with_slashes quote.last_trade_date
    # self.last_trade_price = quote.last_trade_price
    # self.last_trade_realtime_withtime = quote.last_trade_realtime_withtime
    # self.last_trade_size = quote.last_trade_size
    # self.last_trade_time = quote.last_trade_time
    # self.last_trade_with_time = quote.last_trade_with_time
    # self.low = quote.low
    # self.low_52_weeks = quote.low_52_weeks
    # self.low_limit = quote.low_limit
    # self.market_cap_realtime = quote.market_cap_realtime
    # self.market_capitalization = quote.market_capitalization
    # self.more_info = quote.more_info
    # self.moving_average_200_day = quote.moving_average_200_day
    # self.moving_average_50_day = quote.moving_average_50_day
    # self.name = quote.name
    # self.notes = quote.notes
    # self.one_year_target_price = quote.one_year_target_price
    # self.open = quote.open
    # self.order_book = quote.order_book
    # self.pe_ratio = quote.pe_ratio
    # self.pe_ratio_realtime = quote.pe_ratio_realtime
    # self.peg_ratio = quote.peg_ratio
    # self.percent_change_from_200_day_moving_average = quote.percent_change_from_200_day_moving_average
    # self.percent_change_from_50_day_moving_average = quote.percent_change_from_50_day_moving_average
    # self.percent_change_from_52_week_high = quote.percent_change_from_52_week_high
    # self.percent_change_from_52_week_low = quote.percent_change_from_52_week_low
    # self.previous_close = quote.previous_close
    # self.price_eps_estimate_current_year = quote.price_eps_estimate_current_year
    # self.price_eps_Estimate_next_year = quote.price_eps_Estimate_next_year
    # self.price_paid = quote.price_paid
    # self.price_per_book = quote.price_per_book
    # self.price_per_sales = quote.price_per_sales
    # self.revenue = quote.revenue
    # self.shares_outstanding = quote.shares_outstanding
    # self.shares_owned = quote.shares_owned
    # self.short_ratio = quote.short_ratio
    # self.stock_exchange = quote.stock_exchange
    # self.symbol = quote.symbol
    # self.ticker_trend = quote.ticker_trend
    # self.trade_date = quote.trade_date
    # self.trade_links = quote.trade_links
    # self.volume = quote.volume
    # self.weeks_range_52 = quote.weeks_range_52
  end

  # def update_stock_with_quote(quote)
  #   self.symbol = quote.symbol.upcase
  #   self.ask = quote.ask
  #   self.average_daily_volume = quote.average_daily_volume
  #   self.bid = quote.bid
  #   self.ask_realtime = quote.ask_realtime
  #   self.bid_realtime = quote.bid_realtime
  #   self.book_value = quote.book_value
  #   self.change_percent_change = quote.change_percent_change
  #   self.change = quote.change
  #   self.commission = quote.commission
  #   self.change_realtime = quote.change_realtime
  #   self.after_hours_change_realtime = quote.after_hours_change_realtime
  #   self.dividend_share = quote.dividend_share
  #   self.last_trade_date = quote.last_trade_date
  #   self.trade_date = quote.trade_date
  #   self.earnings_share = quote.earnings_share
  #   self.eps_estimate_current_year = quote.eps_estimate_current_year
  #   self.eps_estimate_next_year = quote.eps_estimate_next_year
  #   self.eps_estimate_next_quarter = quote.eps_estimate_next_quarter
  #   self.days_low = quote.days_low
  #   self.days_high = quote.days_high
  #   self.year_low = quote.year_low
  #   self.year_high = quote.year_high
  #   self.more_info = quote.more_info
  #   self.order_book_realtime = quote.order_book_realtime
  #   self.market_capitalization = quote.market_capitalization
  #   self.market_cap_realtime = quote.market_cap_realtime
  #   self.ebitda = quote.ebitda
  #   self.change_from_year_low = quote.change_from_year_low
  #   self.percent_change_from_year_low = quote.percent_change_from_year_low
  #   self.last_trade_realtime_with_time = quote.last_trade_realtime_with_time
  #   self.change_percent_realtime = quote.change_percent_realtime
  #   self.change_from_year_high = quote.change_from_year_high
  #   self.percent_change_from_year_high = quote.percent_change_from_year_high
  #   self.last_trade_with_time = quote.last_trade_with_time
  #   self.last_trade_price_only = quote.last_trade_price_only
  #   self.high_limit = quote.high_limit
  #   self.low_limit = quote.low_limit
  #   self.days_range = quote.days_range
  #   self.days_range_realtime = quote.days_range_realtime
  #   self.fiftyday_moving_average = quote.fiftyday_moving_average
  #   self.two_hundredday_moving_average = quote.two_hundredday_moving_average
  #   self.change_from_two_hundredday_moving_average = quote.change_from_two_hundredday_moving_average
  #   self.percent_change_from_two_hundredday_moving_average = quote.percent_change_from_two_hundredday_moving_average
  #   self.change_from_fiftyday_moving_average = quote.change_from_fiftyday_moving_average
  #   self.percent_change_from_fiftyday_moving_average = quote.percent_change_from_fiftyday_moving_average
  #   self.name = quote.name
  #   self.notes = quote.notes
  #   self.open = quote.open
  #   self.previous_close = quote.previous_close
  #   self.price_paid = quote.price_paid
  #   self.changein_percent = quote.changein_percent
  #   self.price_sales = quote.price_sales
  #   self.price_book = quote.price_book
  #   self.ex_dividend_date = quote.ex_dividend_date
  #   self.pe_ratio = quote.pe_ratio
  #   self.dividend_pay_date = quote.dividend_pay_date
  #   self.pe_ratio_realtime = quote.pe_ratio_realtime
  #   self.peg_ratio = quote.peg_ratio
  #   self.price_eps_estimate_current_year = quote.price_eps_estimate_current_year
  #   self.price_eps_estimate_next_year = quote.price_eps_estimate_next_year
  #   self.symbol = quote.symbol
  #   self.short_ratio = quote.short_ratio
  #   self.last_trade_time = quote.last_trade_time
  #   self.ticker_trend = quote.ticker_trend
  #   self.oneyr_target_price = quote.oneyr_target_price
  #   self.volume = quote.volume
  #   self.holdings_value = quote.holdings_value
  #   self.holdings_value_realtime = quote.holdings_value_realtime
  #   self.year_range = quote.year_range
  #   self.days_value_change = quote.days_value_change
  #   self.days_value_change_realtime = quote.days_value_change_realtime
  #   self.stock_exchange = quote.stock_exchange
  #   self.dividend_yield = quote.dividend_yield
  #   self.percent_change = quote.percent_change
  #   self.date = quote.date
  #   self.open = quote.open
  #   self.high = quote.high
  #   self.low = quote.low
  #   self.close = quote.close
  #   self.adj_close = quote.adj_close
  # end

  def self.ticker(sym)
    Stock.find_by_symbol sym.upcase
  end

  private

  def force_symbol_uppercase
    self.symbol.upcase! unless self.symbol.blank?
  end
end
