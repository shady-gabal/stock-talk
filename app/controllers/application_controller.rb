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


  def set_filter_where_statements(accepted_filters, statements)
    if params[:filter]
      params[:filter].each do |name, val|
        sign = ">"

        if val.blank?
          params[:filter].delete name
        elsif accepted_filters.include?(name)
          parts = val.split(" ")


          if parts.length > 1 && [">", "<", ">=", "<="].include?(parts[0])
            sign = parts[0]
            val = parts[1]
          else
            val = parts[0]
          end

          if name == "insider_net_shares"
            name = "COALESCE(MAX(tot_net_shares), 0)"
            statements = statements.having("#{name} #{sign} ?", val)
          else
            statements = statements.where("#{name} #{sign} ?", val)
          end

        end
      end
    end

    @filters = params[:filter] || {}

    statements
  end
end
