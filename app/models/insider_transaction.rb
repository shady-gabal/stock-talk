class InsiderTransaction < ActiveRecord::Base
  # belongs_to :stock
  belongs_to :stock, foreign_key: :stock_symbol, primary_key: :symbol

  EDGAR_OFFSET_INTERVAL = 25
  EDGAR_SLEEP_INTERVAL = 0.6

  module TransactionType
    Sell = "sell"
    Buy = "buy"
  end

  def self.data_with_transaction(transaction)
    pairs = transaction["values"]
    data = {}

    pairs.each do |pair|
      next if pair.blank?
      field = pair["field"]
      val = pair["value"]

      case field
        when "issueid"
          data[:issue_id] = val
        when "transactiondate"
          data[:transaction_date] = Date.parse_with_slashes val
        when "transactionpricefrom"
          data[:transaction_price_from] = val
        when "numtransactions"
          data[:num_transactions] = val
        when "netshares"
          data[:net_shares] = val
        when "grossshares"
          data[:gross_shares] = val
        when "numsells"
          data[:num_sells] = val
        when "numbuys"
          data[:num_buys] = val
        when "sharessold"
          data[:shares_sold] = val
        when "sharesbought"
          data[:shares_bought] = val
        when "transactionpriceto"
          data[:transaction_price_to] = val
        when "ownershiptype"
          data[:ownership_type] = val
        when "insider_form_type"
          data[:insider_form_type] = val
      end
    end

    if data[:net_shares] > 0
      data[:transaction_type] = TransactionType::Buy
    elsif data[:net_shares] < 0
      data[:transaction_type] = TransactionType::Sell
    end

    data

    # new_transaction = InsiderTransaction.new(data)
    #
    # if save
    #   new_transaction.save
    # end

    # return new_transaction
  end

  def self.stock_ids_for_dates_issue_ids(dates_to_issue_ids)
    issue_ids_to_stock_ids = {}

    round = 0

    dates_to_issue_ids.keys.each do |date_str|
      next unless date_str <= "20170622" && date_str >= "20170621"

      puts "Starting on #{date_str}..."

      issue_ids = dates_to_issue_ids[date_str].flatten

      issue_ids.in_groups_of(20) do |issue_id_group|
        issue_id_group = issue_id_group

        keep_going = true
        offset = 0
        num_rows = nil

        while keep_going
          puts "InsiderTransaction: Processing offset #{offset} for round #{round}"

          ids = issue_id_group.compact.join(",")

          url = "http://edgaronline.api.mashery.com/v2/insiders/transactions.json?transactiondates=#{date_str}&offset=#{offset}&issueids=#{ids}&appkey=#{ENV["ST_EDGAR_API_KEY"]}"

          res = Faraday.get url
          data = JSON.parse(res.body)

          if data.blank? || data["result"].blank?
            puts data
            return nil
          end

          rows = data["result"]["rows"]

          if num_rows.nil?
            puts data["result"]["totalrows"].to_i
          end

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
                issue_id = val.to_s
              elsif field == "issueticker"
                ticker = val.upcase
              end
            end

            if !issue_id.blank? && !ticker.blank? && issue_ids_to_stock_ids[issue_id].blank?
              issue_ids_to_stock_ids[issue_id] = ticker

              # ticker.upcase!
              # stock_id = nil
              #
              # if stock_ids[ticker]
              #   stock_id = stock_ids[ticker]
              # else
              #   stock = Stock.find_by_symbol ticker
              #
              #   if !stock.nil?
              #     stock_ids[ticker] = stock.id
              #     stock_id = stock.id
              #   end
              # end
              #
              # if !stock_id.nil?
              #   issue_ids_to_stock_ids[issue_id.to_s] = stock_id
              # end

            end
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

    puts "Made #{round} API calls to edgar in InsiderTransaction.stock_ids_for_dates_issue_ids"
    issue_ids_to_stock_ids
  end
end
