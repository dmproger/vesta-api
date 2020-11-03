class HomeDataDetails
  attr_reader :period, :type, :current_user

  def initialize(period:, type:, current_user:)
    @period = period
    @type = type
    @current_user = current_user
  end

  def call
    case type
    when 'collected'
      PropertyTenantTransaction.where(property_id: current_user.properties.ids)
          .this_month_till_now(period)
          .includes(:saved_transaction)
    when 'expected'
      # TODO: expected
    else
      # TODO: late
    end
  end
end