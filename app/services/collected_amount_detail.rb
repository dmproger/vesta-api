class CollectedAmountDetail
  attr_reader :period, :current_user

  def initialize(period:, current_user:)
    @period = period
    @current_user = current_user
  end

  def call
    current_user.properties.associated_transactions.within(period)
  end
end