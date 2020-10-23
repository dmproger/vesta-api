class HomeData
  attr_reader :period, :current_user,
              :expected, :collected, :total, :late

  def initialize(period:, current_user:)
    @period = Date.parse("01-#{period}")
    @current_user = current_user
  end

  def call
    @collected = calculate_collected_rent
    @late = calculate_late_rent
    @expected = calculate_expected_rent
    @total = calculate_total_rent

    [total, collected, expected, late]
  end

  private

  # TODO: Handle Yearly, bi-annually and quarterly payment frequencies
  def calculate_collected_rent
    current_user.saved_transactions.within(period).rent.sum(:amount)
  end

  def calculate_expected_rent
    total_expected - collected - late
  end

  def total_expected
    current_user.tenants.monthly.within(period).sum(:price) +
        0 + # annual payments this month TODO
        0 + # bi-annually payments this month TODO
        0 # quarterly payments this month TODO
  end

  def calculate_late_rent
    0 # TODO: implement the functionality
  end

  def calculate_total_rent
    collected + expected + late
  end
end