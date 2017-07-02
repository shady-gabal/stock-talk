module ApplicationHelper

  def number_with_sign(num)
    prefix = ""
    if num > 0
      prefix = "+"
    end

    "#{prefix}#{num}"
  end
end
