class HomeUtils
  def get_due_datetime(date)
    DateTime.parse("#{get_valid_due_date(date)}T09:00")
  end

  def get_valid_due_date(date)
    if date.saturday?
      date + 3.days
    elsif date.sunday?
      date + 2.day
    elsif date.friday?
      date + 3.days
    else
      date + 1.day
    end
  end
end
