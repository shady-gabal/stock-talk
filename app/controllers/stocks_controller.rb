class StocksController < ApplicationController

  PER_PAGE = 15

  def index
    query = params[:query]
    if !query.blank?
      @stocks = Stock.includes(:insider_transactions).search(query).paginate(page: params[:page], per_page: PER_PAGE)
      @current_search_text = query
    else
      @stocks = Stock.includes(:insider_transactions).all.order('updated_at DESC').paginate(page: params[:page], per_page: PER_PAGE)
    end
  end

  def show
    @stock = Stock.find_by_symbol params[:symbol].upcase
  end

end
