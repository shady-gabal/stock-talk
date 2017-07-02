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
end