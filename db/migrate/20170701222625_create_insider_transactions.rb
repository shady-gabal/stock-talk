class CreateInsiderTransactions < ActiveRecord::Migration
  def change
    create_table :insider_transactions do |t|
      t.decimal :transaction_price_from
      t.decimal :transaction_price_to
      t.integer :shares_bought
      t.integer :shares_sold
      t.integer :net_shares, required: true
      t.string :transaction_type
      t.datetime :transaction_date, required: true
      t.integer :num_transactions
      t.string :issue_id
      t.integer :num_buys
      t.integer :num_sells
      t.integer :gross_shares
      t.string :ownership_type
      t.string :transaction_type
      t.string :insider_form_type

      t.string :stock_symbol, index: true

      t.timestamps null: false
    end
  end
end
