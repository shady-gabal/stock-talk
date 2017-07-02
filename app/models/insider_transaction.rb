class InsiderTransaction < ActiveRecord::Base
  belongs_to :stock

  EDGAR_OFFSET_INTERVAL = 25
  EDGAR_SLEEP_INTERVAL = 1.1

  module TransactionType
    Sell = "sell"
    Buy = "buy"
  end

  def self.create_with_transaction(transaction, save: true)
    pairs = transaction["values"]
    new_transaction = InsiderTransaction.new

    pairs.each do |pair|
      next if pair.blank?
      field = pair["field"]
      val = pair["value"]

      case field
        when "issueid"
          new_transaction.issue_id = val
        when "transactiondate"
          new_transaction.transaction_date = Date::strptime(val, "%m/%d/%Y")
        when "transactionpricefrom"
          new_transaction.transaction_price_from = val
        when "numtransactions"
          new_transaction.num_transactions = val
        when "netshares"
          new_transaction.net_shares = val
        when "grossshares"
          new_transaction.gross_shares = val
        when "numsells"
          new_transaction.num_sells = val
        when "numbuys"
          new_transaction.num_buys = val
        when "sharessold"
          new_transaction.shares_sold = val
        when "sharesbought"
          new_transaction.shares_bought = val
        when "transactionpriceto"
          new_transaction.transaction_price_to = val
        when "ownershiptype"
          new_transaction.ownership_type = val
        when "insider_form_type"
          new_transaction.insider_form_type = val
      end
    end

    if new_transaction.net_shares > 0
      new_transaction.transaction_type = TransactionType::Buy
    elsif new_transaction.net_shares < 0
      new_transaction.transaction_type = TransactionType::Sell
    end

    if save
      new_transaction.save
    end

    return new_transaction
  end

  def self.stock_ids_for_dates_issue_ids(dates_to_issue_ids)
    issue_ids_to_stock_ids = {}

    round = 0

    dates_to_issue_ids.keys.each do |date_str|
      issue_ids = dates_to_issue_ids[date_str]

      issue_ids.in_groups_of(50) do |issue_id_group|
        keep_going = true
        offset = 0

        while keep_going
          puts "InsiderTransaction: Processing offset #{offset}"

          ids = issue_id_group.compact.join(",")
          url = "http://edgaronline.api.mashery.com/v2/insiders/transactions.json?transactiondates=#{date_str}&offset=#{offset}&issueids=#{ids}&appkey=#{ENV["ST_EDGAR_API_KEY"]}"

          res = Faraday.get url
          data = JSON.parse(res.body)

          if data.blank? || data["result"].blank?
            puts data
            return nil
          end

          rows = data["result"]["rows"]
          num_rows = data["result"]["totalrows"].to_i

          puts num_rows

          rows.each do |row|
            pairs = row["values"]
            issue_id = nil
            ticker = nil

            pairs.each do |pair|
              next if pair.blank?

              field = pair["field"]
              val = pair["value"]

              if field == "issueid"
                issue_id = val
              elsif field == "issueticker"
                ticker = val
              end
            end

            if !issue_id.blank? && !ticker.blank? && issue_ids_to_stock_ids[issue_id].blank?
              stock = Stock.find_by_symbol ticker.upcase

              if !stock.nil?
                issue_ids_to_stock_ids[issue_id.to_s] = stock.id
              end
            end
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

    puts "Made #{round} API calls to edgar here"
    issue_ids_to_stock_ids
  end
end
