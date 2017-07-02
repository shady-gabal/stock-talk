class StocksController < ApplicationController

  PER_PAGE = 15

  def index
    accepted_sorts = ["last_trade_price", "earnings_per_share", "near_52_weeks", "one_year_target_price", "change_in_percent", "symbol", "insider_net_shares", "insider_avg_price", "insider_num_transactions", "low_52_weeks", "high_52_weeks"]
    sort_name, sort_order = get_sort_params(accepted_sorts, "change_in_percent")

    query = params[:query]
    @stocks = Stock.
        joins("LEFT OUTER JOIN (SELECT DISTINCT insider_transactions.stock_symbol, SUM(insider_transactions.num_transactions) AS tot_transactions, COALESCE(SUM(insider_transactions.net_shares),0) AS tot_net_shares, COALESCE(AVG(insider_transactions.transaction_price_from),0) AS tot_share_avg FROM insider_transactions GROUP BY insider_transactions.stock_symbol) uc ON (uc.stock_symbol = stocks.symbol)").
        select("stocks.*, COALESCE(MAX(tot_transactions), 0) AS insider_num_transactions, COALESCE(MAX(tot_net_shares), 0) AS insider_net_shares, COALESCE(MAX(tot_share_avg), 0) AS insider_avg_price").
        select("LEAST(COALESCE((last_trade_price - low_52_weeks) / last_trade_price,0), COALESCE((last_trade_price - high_52_weeks) / last_trade_price,0)) AS near_52_weeks").
        where("last_trade_price IS NOT NULL AND symbol IS NOT NULL")

    if !query.blank?
      @stocks = @stocks.search(query).paginate(page: params[:page], per_page: PER_PAGE)
      @current_search_text = query
    else
      @stocks = @stocks.all
    end

    @stocks = @stocks.order("#{sort_name} #{sort_order}").group("stocks.id").paginate(page: params[:page], per_page: PER_PAGE)

  end

  def show
    @stock = Stock.find_by_symbol params[:symbol].upcase
  end

end
