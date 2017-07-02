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
    t.string   "symbol"
    t.integer  "stock_id"
    t.datetime "created_at",             null: false
    t.datetime "updated_at",             null: false
  end

  create_table "stocks", force: :cascade do |t|
    t.string   "symbol"
    t.decimal  "ask"
    t.decimal  "average_daily_volume"
    t.decimal  "bid"
    t.decimal  "ask_realtime"
    t.decimal  "bid_realtime"
    t.decimal  "book_value"
    t.decimal  "change_percent_change"
    t.decimal  "change"
    t.decimal  "commission"
    t.decimal  "change_realtime"
    t.decimal  "after_hours_change_realtime"
    t.decimal  "dividend_share"
    t.decimal  "last_trade_date"
    t.decimal  "trade_date"
    t.decimal  "earnings_share"
    t.decimal  "eps_estimate_current_year"
    t.decimal  "eps_estimate_next_year"
    t.decimal  "eps_estimate_next_quarter"
    t.decimal  "days_low"
    t.decimal  "days_high"
    t.decimal  "year_low"
    t.decimal  "year_high"
    t.string   "more_info"
    t.decimal  "order_book_realtime"
    t.decimal  "market_capitalization"
    t.decimal  "market_cap_realtime"
    t.decimal  "ebitda"
    t.decimal  "change_from_year_low"
    t.decimal  "percent_change_from_year_low"
    t.decimal  "last_trade_realtime_with_time"
    t.decimal  "change_percent_realtime"
    t.decimal  "change_from_year_high"
    t.decimal  "percent_change_from_year_high"
    t.decimal  "last_trade_with_time"
    t.decimal  "last_trade_price_only"
    t.decimal  "high_limit"
    t.decimal  "low_limit"
    t.decimal  "days_range"
    t.decimal  "days_range_realtime"
    t.decimal  "fiftyday_moving_average"
    t.decimal  "two_hundredday_moving_average"
    t.decimal  "change_from_two_hundredday_moving_average"
    t.decimal  "percent_change_from_two_hundredday_moving_average"
    t.decimal  "change_from_fiftyday_moving_average"
    t.decimal  "percent_change_from_fiftyday_moving_average"
    t.string   "name"
    t.string   "notes"
    t.decimal  "open"
    t.decimal  "previous_close"
    t.decimal  "price_paid"
    t.decimal  "changein_percent"
    t.decimal  "price_sales"
    t.decimal  "price_book"
    t.decimal  "ex_dividend_date"
    t.decimal  "pe_ratio"
    t.decimal  "dividend_pay_date"
    t.decimal  "pe_ratio_realtime"
    t.decimal  "peg_ratio"
    t.decimal  "price_eps_estimate_current_year"
    t.decimal  "price_eps_estimate_next_year"
    t.decimal  "short_ratio"
    t.decimal  "last_trade_time"
    t.decimal  "ticker_trend"
    t.decimal  "oneyr_target_price"
    t.decimal  "volume"
    t.decimal  "holdings_value"
    t.decimal  "holdings_value_realtime"
    t.decimal  "year_range"
    t.decimal  "days_value_change"
    t.decimal  "days_value_change_realtime"
    t.decimal  "stock_exchange"
    t.decimal  "dividend_yield"
    t.decimal  "percent_change"
    t.decimal  "date"
    t.decimal  "high"
    t.decimal  "low"
    t.decimal  "close"
    t.decimal  "adj_close"
    t.datetime "created_at",                                        null: false
    t.datetime "updated_at",                                        null: false
  end

  add_index "stocks", ["name"], name: "index_stocks_on_name", using: :btree
  add_index "stocks", ["symbol"], name: "index_stocks_on_symbol", using: :btree

end
