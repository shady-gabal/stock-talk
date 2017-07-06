class CreateStocks < ActiveRecord::Migration
  def change
    create_table :stocks do |t|
      t.string :symbol, index: true
      #
      # t.decimal :ask
      # t.decimal :average_daily_volume
      # t.decimal :bid
      # t.decimal :ask_realtime
      # t.decimal :bid_realtime
      # t.decimal :book_value
      # t.decimal :change_percent_change
      # t.decimal :change
      # t.decimal :commission
      # t.decimal :change_realtime
      # t.decimal :after_hours_change_realtime
      # t.decimal :dividend_share
      # t.decimal :last_trade_date
      # t.decimal :trade_date
      # t.decimal :earnings_share
      # t.decimal :eps_estimate_current_year
      # t.decimal :eps_estimate_next_year
      # t.decimal :eps_estimate_next_quarter
      # t.decimal :days_low
      # t.decimal :days_high
      # t.decimal :year_low
      # t.decimal :year_high
      # t.string  :more_info
      # t.decimal :order_book_realtime
      # t.decimal :market_capitalization
      # t.decimal :market_cap_realtime
      # t.decimal :ebitda
      # t.decimal :change_from_year_low
      # t.decimal :percent_change_from_year_low
      # t.decimal :last_trade_realtime_with_time
      # t.decimal :change_percent_realtime
      # t.decimal :change_from_year_high
      # t.decimal :percent_change_from_year_high
      # t.string  :last_trade_with_time
      # t.decimal :last_trade_price_only
      # t.decimal :high_limit
      # t.decimal :low_limit
      #
      # t.string  :days_range_realtime
      # t.decimal :fiftyday_moving_average
      # t.decimal :two_hundredday_moving_average
      # t.decimal :change_from_two_hundredday_moving_average
      # t.decimal :percent_change_from_two_hundredday_moving_average
      # t.decimal :change_from_fiftyday_moving_average
      # t.decimal :percent_change_from_fiftyday_moving_average
      # t.string  :name, index: true
      # t.string  :notes
      # t.decimal :open
      # t.decimal :previous_close
      # t.decimal :price_paid
      # t.decimal :changein_percent
      # t.decimal :price_sales
      # t.decimal :price_book
      # t.decimal :ex_dividend_date
      # t.decimal :pe_ratio
      # t.decimal :dividend_pay_date
      # t.decimal :pe_ratio_realtime
      # t.decimal :peg_ratio
      # t.decimal :price_eps_estimate_current_year
      # t.decimal :price_eps_estimate_next_year
      # t.decimal :short_ratio
      # t.decimal :last_trade_time
      # t.decimal :ticker_trend
      # t.decimal :oneyr_target_price
      # t.decimal :volume
      # t.decimal :holdings_value
      # t.decimal :holdings_value_realtime
      # t.decimal :year_range
      # t.decimal :days_value_change
      # t.decimal :days_value_change_realtime
      # t.decimal :stock_exchange
      # t.decimal :dividend_yield
      # t.decimal :percent_change
      # t.decimal :date
      # t.decimal :open
      # t.decimal :high
      # t.decimal :low
      # t.decimal :close
      # t.decimal :adj_close
      #


      
      t.decimal :after_hours_change_real_time
      t.decimal :annualized_gain
      t.decimal :ask
      t.decimal :ask_real_time
      t.decimal :ask_size
      t.decimal :average_daily_volume
      t.decimal :bid
      t.decimal :bid_real_time
      t.decimal :bid_size
      t.decimal :book_value
      t.decimal :change
      t.decimal :change_from_200_day_moving_average
      t.decimal :change_from_50_day_moving_average
      t.decimal :change_from_52_week_high
      t.decimal :change_from_52_week_low
      t.decimal :change_in_percent
      t.decimal :change_percent_realtime
      t.decimal :change_real_time
      t.decimal :close
      t.decimal :comission
      t.decimal :day_value_change
      t.decimal :day_value_change_realtime
      t.string :days_range
      t.string :days_range_realtime
      t.datetime :dividend_pay_date
      t.decimal :dividend_per_share
      t.decimal :dividend_yield
      t.decimal :earnings_per_share
      t.string  :ebitda
      t.decimal :eps_estimate_current_year
      t.decimal :eps_estimate_next_quarter
      t.decimal :eps_estimate_next_year
      t.decimal :error_indicator
      t.datetime :ex_dividend_date
      t.decimal :float_shares
      t.decimal :high
      t.decimal :high_52_weeks
      t.decimal :high_limit
      t.decimal :holdings_gain
      t.decimal :holdings_gain_percent
      t.decimal :holdings_gain_percent_realtime
      t.decimal :holdings_gain_realtime
      t.decimal :holdings_value
      t.decimal :holdings_value_realtime
      t.datetime :last_trade_date
      t.decimal :last_trade_price
      t.decimal :last_trade_realtime_withtime
      t.decimal :last_trade_size
      t.decimal :last_trade_time
      t.string :last_trade_with_time
      t.decimal :low
      t.decimal :low_52_weeks
      t.decimal :low_limit
      t.string :market_cap_realtime
      t.string :market_capitalization
      t.string :more_info
      t.decimal :moving_average_200_day
      t.decimal :moving_average_50_day
      t.string :name
      t.string :notes
      t.decimal :one_year_target_price
      t.decimal :open
      t.decimal :order_book
      t.decimal :pe_ratio
      t.decimal :pe_ratio_realtime
      t.decimal :peg_ratio
      t.string :percent_change_from_200_day_moving_average
      t.string :percent_change_from_50_day_moving_average
      t.decimal :percent_change_from_52_week_high
      t.decimal :percent_change_from_52_week_low
      t.decimal :previous_close
      t.decimal :price_eps_estimate_current_year
      t.decimal :price_eps_estimate_next_year
      t.decimal :price_paid
      t.decimal :price_per_book
      t.decimal :price_per_sales
      t.string  :revenue
      t.integer :shares_outstanding, :limit => 8
      t.decimal :shares_owned
      t.decimal :short_ratio
      t.string :stock_exchange
      t.string :symbol
      t.decimal :ticker_trend
      t.datetime :trade_date
      t.decimal :trade_links
      t.integer :volume, :limit => 8
      t.string :weeks_range_52


      t.timestamps null: false
    end
  end
end
