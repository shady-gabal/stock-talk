class Stock < ActiveRecord::Base
  include SearchCop

  has_many :insider_transactions

  validate :force_symbol_uppercase
  validates :symbol, presence: true, allow_blank: false

  EDGAR_OFFSET_INTERVAL = 25
  EDGAR_SLEEP_INTERVAL = 1.1

  search_scope :search do
    attributes :name, :symbol
  end

  def self.fetch_all_stock_names
    res = Faraday.get("https://www.quandl.com/api/v3/datatables/WIKI/PRICES.json?date=2017-6-30&api_key=#{ENV["ST_QUANDL_API_KEY"]}")
    body = JSON.parse(res.body)

    stocks = body["datatable"]["data"]

    stock_names = stocks.map {|s| s[0]}

    stock_names
  end

  def self.create_stocks
    Stock.destroy_all

    new_stocks = []

    stock_names = Stock.fetch_all_stock_names

    stock_names.in_groups_of(99) do |curr_stock_names|
      quotes = StockQuote::Stock.quote(curr_stock_names.compact)
      new_stocks.concat Stock.create_stocks_with_quotes(quotes, false)
    end

    status = Stock.import Stock.column_names, new_stocks
  end

  def update_stock
    quote = StockQuote::Stock.quote(self.symbol)
    self.update_stock_with_quote(quote)
  end

  def self.create_stocks_with_quotes(quotes, save=true)
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
    issue_ids = {}
    dates_to_issue_ids = {}
    round = 0

    date_strs.each do |str|
      ["sharessold", "sharesbought"].each do |filter|
        offset = 0
        keep_going = true

        while keep_going
          puts "Stock update_insider_data: Processing offset #{offset}"

          url = "http://edgaronline.api.mashery.com/v2/insiders/summary.json?appkey=#{ENV["ST_EDGAR_API_KEY"]}&offset=#{offset}&transactiondates=#{str}&filter=#{filter} gt 0"
          res = Faraday.get url
          data = JSON.parse(res.body)

          if data.blank? || data["result"].blank?
            puts data
            return
          else
            transactions = data["result"]["rows"]
            num_rows = data["result"]["totalrows"].to_i
            puts num_rows

            transactions.each do |transaction|
              next if transaction.blank?

              new_transaction = InsiderTransaction.create_with_transaction(transaction, save: false)
              issue_id = new_transaction.issue_id

              if new_transaction.transaction_date
                date_str = new_transaction.transaction_date.strftime("%Y%m%d")

                dates_to_issue_ids[date_str] = [] if dates_to_issue_ids[date_str].blank?
                dates_to_issue_ids[date_str] << issue_id
              end

              issue_ids[issue_id] = {transactions: []} if issue_ids[issue_id].blank?
              issue_ids[issue_id][:transactions] << new_transaction
            end

            round += 1
            if round % 2 == 0
              sleep EDGAR_SLEEP_INTERVAL
            end

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

    issue_ids_to_stock_ids = InsiderTransaction.stock_ids_for_dates_issue_ids(dates_to_issue_ids)
    return if issue_ids_to_stock_ids.nil? #errored

    #get issue ids and match to stock names
    issue_ids.each do |issue_id, issue_id_data|
      transactions = issue_id_data[:transactions]

      stock_id = issue_ids_to_stock_ids[issue_id.to_s]

      if !stock_id.blank?
        transactions.each {|t| t.stock_id = stock_id}
      end
    end

    puts "Made #{round} API calls to edgar here"
    status = InsiderTransaction.import InsiderTransaction.column_names, issue_ids.values
  end

  def update_stock_with_quote(quote)
    self.symbol = quote.symbol.upcase
    self.ask = quote.ask
    self.average_daily_volume = quote.average_daily_volume
    self.bid = quote.bid
    self.ask_realtime = quote.ask_realtime
    self.bid_realtime = quote.bid_realtime
    self.book_value = quote.book_value
    self.change_percent_change = quote.change_percent_change
    self.change = quote.change
    self.commission = quote.commission
    self.change_realtime = quote.change_realtime
    self.after_hours_change_realtime = quote.after_hours_change_realtime
    self.dividend_share = quote.dividend_share
    self.last_trade_date = quote.last_trade_date
    self.trade_date = quote.trade_date
    self.earnings_share = quote.earnings_share
    self.eps_estimate_current_year = quote.eps_estimate_current_year
    self.eps_estimate_next_year = quote.eps_estimate_next_year
    self.eps_estimate_next_quarter = quote.eps_estimate_next_quarter
    self.days_low = quote.days_low
    self.days_high = quote.days_high
    self.year_low = quote.year_low
    self.year_high = quote.year_high
    self.more_info = quote.more_info
    self.order_book_realtime = quote.order_book_realtime
    self.market_capitalization = quote.market_capitalization
    self.market_cap_realtime = quote.market_cap_realtime
    self.ebitda = quote.ebitda
    self.change_from_year_low = quote.change_from_year_low
    self.percent_change_from_year_low = quote.percent_change_from_year_low
    self.last_trade_realtime_with_time = quote.last_trade_realtime_with_time
    self.change_percent_realtime = quote.change_percent_realtime
    self.change_from_year_high = quote.change_from_year_high
    self.percent_change_from_year_high = quote.percent_change_from_year_high
    self.last_trade_with_time = quote.last_trade_with_time
    self.last_trade_price_only = quote.last_trade_price_only
    self.high_limit = quote.high_limit
    self.low_limit = quote.low_limit
    self.days_range = quote.days_range
    self.days_range_realtime = quote.days_range_realtime
    self.fiftyday_moving_average = quote.fiftyday_moving_average
    self.two_hundredday_moving_average = quote.two_hundredday_moving_average
    self.change_from_two_hundredday_moving_average = quote.change_from_two_hundredday_moving_average
    self.percent_change_from_two_hundredday_moving_average = quote.percent_change_from_two_hundredday_moving_average
    self.change_from_fiftyday_moving_average = quote.change_from_fiftyday_moving_average
    self.percent_change_from_fiftyday_moving_average = quote.percent_change_from_fiftyday_moving_average
    self.name = quote.name
    self.notes = quote.notes
    self.open = quote.open
    self.previous_close = quote.previous_close
    self.price_paid = quote.price_paid
    self.changein_percent = quote.changein_percent
    self.price_sales = quote.price_sales
    self.price_book = quote.price_book
    self.ex_dividend_date = quote.ex_dividend_date
    self.pe_ratio = quote.pe_ratio
    self.dividend_pay_date = quote.dividend_pay_date
    self.pe_ratio_realtime = quote.pe_ratio_realtime
    self.peg_ratio = quote.peg_ratio
    self.price_eps_estimate_current_year = quote.price_eps_estimate_current_year
    self.price_eps_estimate_next_year = quote.price_eps_estimate_next_year
    self.symbol = quote.symbol
    self.short_ratio = quote.short_ratio
    self.last_trade_time = quote.last_trade_time
    self.ticker_trend = quote.ticker_trend
    self.oneyr_target_price = quote.oneyr_target_price
    self.volume = quote.volume
    self.holdings_value = quote.holdings_value
    self.holdings_value_realtime = quote.holdings_value_realtime
    self.year_range = quote.year_range
    self.days_value_change = quote.days_value_change
    self.days_value_change_realtime = quote.days_value_change_realtime
    self.stock_exchange = quote.stock_exchange
    self.dividend_yield = quote.dividend_yield
    self.percent_change = quote.percent_change
    self.date = quote.date
    self.open = quote.open
    self.high = quote.high
    self.low = quote.low
    self.close = quote.close
    self.adj_close = quote.adj_close
  end

  private

  def force_symbol_uppercase
    self.symbol.upcase! unless self.symbol.blank?
  end
end
