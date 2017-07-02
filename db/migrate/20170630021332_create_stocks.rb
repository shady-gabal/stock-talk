class CreateStocks < ActiveRecord::Migration
  def change
    create_table :stocks do |t|
      t.string :symbol, index: true

      t.decimal :ask
      t.decimal :average_daily_volume
      t.decimal :bid
      t.decimal :ask_realtime
      t.decimal :bid_realtime
      t.decimal :book_value
      t.decimal :change_percent_change
      t.decimal :change
      t.decimal :commission
      t.decimal :change_realtime
      t.decimal :after_hours_change_realtime
      t.decimal :dividend_share
      t.decimal :last_trade_date
      t.decimal :trade_date
      t.decimal :earnings_share
      t.decimal :eps_estimate_current_year
      t.decimal :eps_estimate_next_year
      t.decimal :eps_estimate_next_quarter
      t.decimal :days_low
      t.decimal :days_high
      t.decimal :year_low
      t.decimal :year_high
      t.string  :more_info
      t.decimal :order_book_realtime
      t.decimal :market_capitalization
      t.decimal :market_cap_realtime
      t.decimal :ebitda
      t.decimal :change_from_year_low
      t.decimal :percent_change_from_year_low
      t.decimal :last_trade_realtime_with_time
      t.decimal :change_percent_realtime
      t.decimal :change_from_year_high
      t.decimal :percent_change_from_year_high
      t.string  :last_trade_with_time
      t.decimal :last_trade_price_only
      t.decimal :high_limit
      t.decimal :low_limit

      t.string  :days_range_realtime
      t.decimal :fiftyday_moving_average
      t.decimal :two_hundredday_moving_average
      t.decimal :change_from_two_hundredday_moving_average
      t.decimal :percent_change_from_two_hundredday_moving_average
      t.decimal :change_from_fiftyday_moving_average
      t.decimal :percent_change_from_fiftyday_moving_average
      t.string  :name, index: true
      t.string  :notes
      t.decimal :open
      t.decimal :previous_close
      t.decimal :price_paid
      t.decimal :changein_percent
      t.decimal :price_sales
      t.decimal :price_book
      t.decimal :ex_dividend_date
      t.decimal :pe_ratio
      t.decimal :dividend_pay_date
      t.decimal :pe_ratio_realtime
      t.decimal :peg_ratio
      t.decimal :price_eps_estimate_current_year
      t.decimal :price_eps_estimate_next_year
      t.decimal :short_ratio
      t.decimal :last_trade_time
      t.decimal :ticker_trend
      t.decimal :oneyr_target_price
      t.decimal :volume
      t.decimal :holdings_value
      t.decimal :holdings_value_realtime
      t.decimal :year_range
      t.decimal :days_value_change
      t.decimal :days_value_change_realtime
      t.decimal :stock_exchange
      t.decimal :dividend_yield
      t.decimal :percent_change
      t.decimal :date
      t.decimal :open
      t.decimal :high
      t.decimal :low
      t.decimal :close
      t.decimal :adj_close


      # t.decimal :current_stock_price
      # t.decimal :fifty_two_low
      # t.decimal :fifty_two_high
      # t.decimal :five_day_high
      # t.decimal :five_day_low
      # t.decimal :earnings_per_share
      # t.jsonb   :five_day_changes
      # t.decimal :five_day_total_change
      # t.t.jsonb :ten_day_insider_changes
      # t.decimal :ten_day_insider_total_change
      # t.datetime :next_earnings_date
      # t.decimal :ask_price
      # t.decimal :bid_price
      # t.decimal :ask_realtime
      # t.decimal :bid_realtime
      # t.decimal :change_percent_change
      # t.decimal :change
      # t.decimal :change_realtime
      # t.decimal :after_hours_change_realtime
      # t.decimal :dividend_share
      # t.decimal :earnings_share
      # t.decimal :eps_estimate_current_year
      # t.decimal :eps_estimate_next_year
      # t.decimal :eps_estimate_next_quarter
      # t.decimal :days_low
      # t.decimal :days_high
      # t.decimal :year_low
      # t.decimal :year_high
      #
      # t.decimal :average_daily_volue
      # t.string :exchange

     # symbol, ask, average_daily_volume, bid, ask_realtime, bid_realtime, book_value, change_percent_change, change, commission, change_realtime, after_hours_change_realtime, dividend_share, last_trade_date, trade_date, earnings_share, error_indicationreturnedforsymbolchangedinvalid, eps_estimate_current_year, eps_estimate_next_year, eps_estimate_next_quarter, days_low, days_high, year_low, year_high, holdings_gain_percent, annualized_gain, holdings_gain, holdings_gain_percent_realtime, holdings_gain_realtime, more_info, order_book_realtime, market_capitalization, market_cap_realtime, ebitda, change_from_year_low, percent_change_from_year_low, last_trade_realtime_with_time, change_percent_realtime, change_from_year_high, percent_change_from_year_high, last_trade_with_time, last_trade_price_only, high_limit, low_limit, days_range, days_range_realtime, fiftyday_moving_average, two_hundredday_moving_average, change_from_two_hundredday_moving_average, percent_change_from_two_hundredday_moving_average, change_from_fiftyday_moving_average, percent_change_from_fiftyday_moving_average, name, notes, open, previous_close, price_paid, changein_percent, price_sales, price_book, ex_dividend_date, pe_ratio, dividend_pay_date, pe_ratio_realtime, peg_ratio, price_eps_estimate_current_year, price_eps_estimate_next_year, symbol, shares_owned, short_ratio, last_trade_time, ticker_trend, oneyr_target_price, volume, holdings_value, holdings_value_realtime, year_range, days_value_change, days_value_change_realtime, stock_exchange, dividend_yield, percent_change, error_indicationreturnedforsymbolchangedinvalid, date, open, high, low, close, adj_close


      t.timestamps null: false
    end
  end
end
