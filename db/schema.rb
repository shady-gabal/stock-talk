# encoding: UTF-8
# This file is auto-generated from the current state of the database. Instead
# of editing this file, please use the migrations feature of Active Record to
# incrementally modify your database, and then regenerate this schema definition.
#
# Note that this schema.rb definition is the authoritative source for your
# database schema. If you need to create the application database on another
# system, you should be using db:schema:load, not running all the migrations
# from scratch. The latter is a flawed and unsustainable approach (the more migrations
# you'll amass, the slower it'll run and the greater likelihood for issues).
#
# It's strongly recommended that you check this file into your version control system.

ActiveRecord::Schema.define(version: 20170701222625) do

  # These are extensions that must be enabled in order to support this database
  enable_extension "plpgsql"

  create_table "insider_transactions", force: :cascade do |t|
    t.decimal  "transaction_price_from"
    t.decimal  "transaction_price_to"
    t.integer  "shares_bought"
    t.integer  "shares_sold"
    t.integer  "net_shares"
    t.string   "transaction_type"
    t.datetime "transaction_date"
    t.integer  "num_transactions"
    t.string   "issue_id"
    t.integer  "num_buys"
    t.integer  "num_sells"
    t.integer  "gross_shares"
    t.string   "ownership_type"
    t.string   "insider_form_type"
    t.string   "stock_symbol"
    t.datetime "created_at",             null: false
    t.datetime "updated_at",             null: false
  end

  add_index "insider_transactions", ["stock_symbol"], name: "index_insider_transactions_on_stock_symbol", using: :btree

  create_table "stocks", force: :cascade do |t|
    t.string   "symbol"
    t.decimal  "after_hours_change_real_time"
    t.decimal  "annualized_gain"
    t.decimal  "ask"
    t.decimal  "ask_real_time"
    t.decimal  "ask_size"
    t.decimal  "average_daily_volume"
    t.decimal  "bid"
    t.decimal  "bid_real_time"
    t.decimal  "bid_size"
    t.decimal  "book_value"
    t.decimal  "change"
    t.decimal  "change_from_200_day_moving_average"
    t.decimal  "change_from_50_day_moving_average"
    t.decimal  "change_from_52_week_high"
    t.decimal  "change_from_52_week_low"
    t.decimal  "change_in_percent"
    t.decimal  "change_percent_realtime"
    t.decimal  "change_real_time"
    t.decimal  "close"
    t.decimal  "comission"
    t.decimal  "day_value_change"
    t.decimal  "day_value_change_realtime"
    t.string   "days_range"
    t.string   "days_range_realtime"
    t.datetime "dividend_pay_date"
    t.decimal  "dividend_per_share"
    t.decimal  "dividend_yield"
    t.decimal  "earnings_per_share"
    t.string   "ebitda"
    t.decimal  "eps_estimate_current_year"
    t.decimal  "eps_estimate_next_quarter"
    t.decimal  "eps_estimate_next_year"
    t.decimal  "error_indicator"
    t.datetime "ex_dividend_date"
    t.decimal  "float_shares"
    t.decimal  "high"
    t.decimal  "high_52_weeks"
    t.decimal  "high_limit"
    t.decimal  "holdings_gain"
    t.decimal  "holdings_gain_percent"
    t.decimal  "holdings_gain_percent_realtime"
    t.decimal  "holdings_gain_realtime"
    t.decimal  "holdings_value"
    t.decimal  "holdings_value_realtime"
    t.datetime "last_trade_date"
    t.decimal  "last_trade_price"
    t.decimal  "last_trade_realtime_withtime"
    t.decimal  "last_trade_size"
    t.decimal  "last_trade_time"
    t.string   "last_trade_with_time"
    t.decimal  "low"
    t.decimal  "low_52_weeks"
    t.decimal  "low_limit"
    t.string   "market_cap_realtime"
    t.string   "market_capitalization"
    t.string   "more_info"
    t.decimal  "moving_average_200_day"
    t.decimal  "moving_average_50_day"
    t.string   "name"
    t.string   "notes"
    t.decimal  "one_year_target_price"
    t.decimal  "open"
    t.decimal  "order_book"
    t.decimal  "pe_ratio"
    t.decimal  "pe_ratio_realtime"
    t.decimal  "peg_ratio"
    t.string   "percent_change_from_200_day_moving_average"
    t.string   "percent_change_from_50_day_moving_average"
    t.decimal  "percent_change_from_52_week_high"
    t.decimal  "percent_change_from_52_week_low"
    t.decimal  "previous_close"
    t.decimal  "price_eps_estimate_current_year"
    t.decimal  "price_eps_estimate_next_year"
    t.decimal  "price_paid"
    t.decimal  "price_per_book"
    t.decimal  "price_per_sales"
    t.string   "revenue"
    t.integer  "shares_outstanding",                         limit: 8
    t.decimal  "shares_owned"
    t.decimal  "short_ratio"
    t.string   "stock_exchange"
    t.decimal  "ticker_trend"
    t.datetime "trade_date"
    t.decimal  "trade_links"
    t.integer  "volume",                                     limit: 8
    t.string   "weeks_range_52"
    t.datetime "created_at",                                           null: false
    t.datetime "updated_at",                                           null: false
  end

  add_index "stocks", ["symbol"], name: "index_stocks_on_symbol", using: :btree

end
