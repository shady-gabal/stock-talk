module ApplicationHelper

  def number_with_sign(num, commas: false)
    return nil if num.blank?

    prefix = ""
    if num > 0
      prefix = "+"
    end

    if commas
      num = number_with_delimiter(num, delimiter: ",")
    end

    "#{prefix}#{num}"
  end

  def pos_neg_class(num)
    return nil if num.blank?

    if num < 0
      "negative"
    elsif num > 0
      "positive"
    else
      ""
    end
  end

  def caret_down
    '<i class="caret down icon"></i>'.html_safe
  end

  def caret_up
    '<i class="caret up icon"></i>'.html_safe
  end

  def sort_url(target_sort_name=nil)
    target_sort_name = target_sort_name || @curr_sort_name

    if "#{target_sort_name}_desc" == @active_sort_name
      order = "asc"
    else
      order = "desc"
    end

    uri = Addressable::URI.parse(request.original_url)
    p = uri.query_values || {}
    p['sort'] = "#{target_sort_name}_#{order}"
    uri.query_values = p

    uri.to_s
  end

  def sort_active?(target_sort_name=nil)
    target_sort_name = target_sort_name || @curr_sort_name

    return (@active_sort_name ==  "#{target_sort_name}_desc" || @active_sort_name ==  "#{target_sort_name}_asc")
  end

  def sort_caret(target_sort_name=nil)
    target_sort_name = target_sort_name || @curr_sort_name

    if @active_sort_name ==  "#{target_sort_name}_desc"
      caret_down
    elsif @active_sort_name ==  "#{target_sort_name}_asc"
      caret_up
    end
  end

  def news_url(symbol)
    "https://www.google.com/search?q=#{symbol.downcase}+stock+news"
    # "http://quotes.wsj.com/#{symbol.upcase}"
  end

end
