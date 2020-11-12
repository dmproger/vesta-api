class HomeData
  attr_reader :period, :current_user,
              :expected, :collected, :total, :late_collected, :late_expected, :on_time_collection

  def initialize(period:, current_user:)
    @period = period
    @current_user = current_user
    @late_collected = []
    @late_expected = []
  end

  def call
    @collected = calculate_collected_rent
    @expected = calculate_expected_rent
    @total = calculate_total_rent

    [total, collected, expected, late_expected.sum].map(&:to_f)
  end

  private

  def calculate_collected_rent
    current_user.saved_transactions
        .includes(:associated_transaction)
        .where.not(associated_transactions: {id: nil})
        .within(period).sum(:amount)
  end

  def calculate_expected_rent
    total_expected - late_expected.sum
  end

  def total_expected
    expected_rent = []
    current_user.tenants.within(period).each do |tenant|
      ptt = tenant.property_tenants.this_month(period).first

      case tenant.payment_frequency
      when 'monthly'
        add_to_collection(ptt, tenant, expected_rent)
      when 'annually'
        add_to_collection(ptt, tenant, expected_rent) if tenant.start_date.month == period.month
      when 'bi-annually'
        add_to_collection(ptt, tenant, expected_rent) if tenant.start_date.month == period.month ||
            (tenant.start_date + 6.months).month == period.month
      when 'quarterly'
        add_to_collection(ptt, tenant, expected_rent) if tenant.start_date.month == period.month ||
            (tenant.start_date + 3.months).month == period.month ||
            (tenant.start_date + 6.months).month == period.month ||
            (tenant.start_date + 9.months).month == period.month
      end
    end

    expected_rent.sum + late_expected.sum
  end

  def add_to_collection(ptt, tenant, expected_rent)
    if ptt.present?
      ptt.saved_transactions.each do |saved_transaction|
        late_collected << tenant.price if saved_transaction.transaction_date&.day.to_i > tenant.day_of_month
      end
    else
      if (period - (tenant.day_of_month - 1)) < Date.current
        late_expected << tenant.price
      else
        expected_rent << tenant.price
      end
    end
  end

  def calculate_late_rent
    late_expected.sum
  end

  def calculate_total_rent
    collected + expected + late_expected.sum
  end
end