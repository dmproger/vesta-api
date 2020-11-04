class HomeData
  attr_reader :period, :current_user,
              :expected, :collected, :total, :late_rents, :late

  def initialize(period:, current_user:)
    @period = period
    @current_user = current_user
    @late_rents = []
  end

  def call
    @collected = calculate_collected_rent
    @expected = calculate_expected_rent
    @total = calculate_total_rent

    [total, collected, expected, late]
  end

  private

  def calculate_collected_rent
    current_user.saved_transactions.within(period).rent.sum(:amount)
  end

  def calculate_expected_rent
    total_expected - collected - late
  end

  def total_expected
    on_time = []
    current_user.tenants.within(period).each do |tenant|
      ptt = tenant.property_tenant_transactions.this_month(period).first

      case tenant.payment_frequency
      when 'monthly'
        add_to_collection(on_time, ptt, tenant)
      when 'annually'
        add_to_collection(on_time, ptt, tenant) if tenant.start_date.month == period.month
      when 'bi-annually'
        add_to_collection(on_time, ptt, tenant) if tenant.start_date.month == period.month ||
            (tenant.start_date + 6.months).month == period.month
      when 'quarterly'
        add_to_collection(on_time, ptt, tenant) if tenant.start_date.month == period.month ||
            (tenant.start_date + 3.months).month == period.month ||
            (tenant.start_date + 6.months).month == period.month ||
            (tenant.start_date + 9.months).month == period.month
      end
    end

    @late = calculate_late_rent
    on_time.sum + late
  end

  def add_to_collection(on_time, ptt, tenant)
    if ptt&.saved_transaction&.transaction_date&.day.to_i > tenant.day_of_month
      late_rents << tenant.price
    else
      on_time << tenant.price
    end
  end

  def calculate_late_rent
    late_rents.sum
  end

  def calculate_total_rent
    collected + expected + late
  end
end