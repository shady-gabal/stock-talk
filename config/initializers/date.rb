class Date
  def self.date_strings_in_past_days(num_days=30)
    date_strs = []

    num_days.times do |num|
      date = num.days.ago

      date_strs << date.strftime("%Y%m%d")
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
end