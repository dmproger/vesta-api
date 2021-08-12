module PeriodParams
  private

  def set_period
    @period =
      case [params[:start_date].present?, params[:end_date].present?]
      when [true, true]
        Date.parse(params[:start_date])..Date.parse(params[:end_date])
      when [true, false]
        Date.parse(params[:start_date])..
      when [false, true]
        ..Date.parse(params[:end_date])
      else
        (Date.current - 100.years)..(Date.current + 100.years)
      end
  end
end
