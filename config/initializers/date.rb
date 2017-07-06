class Date
  def self.date_strings_in_past_days(num_days=30)
    date_strs = []

    num_days.times do |num|
      date = num.days.ago

      date_strs << date.compacted_str
    end

    date_strs
  end

  def compacted_str
    self.strftime("%Y%m%d")
  end

  def self.parse_with_slashes(date_str)
    begin
      Date::strptime(date_str, "%m/%d/%Y")
    rescue => e
      nil
    end
  end

  def human_readable(time: true)
    format_str = "%A %B %d, %Y"
    format_str += " at %I:%M %P" if time
    strftime(format_str)
  end
end