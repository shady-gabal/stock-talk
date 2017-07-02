class ApplicationController < ActionController::Base
  # Prevent CSRF attacks by raising an exception.
  # For APIs, you may want to use :null_session instead.
  protect_from_forgery with: :exception

  def get_sort_params(accepted_sorts, default_sort=nil)
    default_sort = accepted_sorts.first if default_sort.blank?

    @active_sort_name = params[:sort]
    sort_parts = @active_sort_name.nil? ? [] : @active_sort_name.split("_")
    sort_order = (sort_parts.last && sort_parts.last.downcase == 'desc') ? 'DESC' : 'ASC'

    sort_name = sort_parts[0...sort_parts.length - 1].join("_")
    sort_name = accepted_sorts.include?(sort_name) ? sort_name : default_sort

    return sort_name, sort_order
  end

end
