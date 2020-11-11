class ExpectedAmountDetail
  attr_reader :period, :current_user, :expected, :late, :type

  def initialize(period:, current_user:, type:)
    @period = period
    @current_user = current_user
    @type = type
    @expected = []
    @late = []
  end

  def call
    evaluate_expected_detail

    (type == 'expected') ? expected : late
  end

  private

  def evaluate_expected_detail
    current_user.tenants.within(period).each do |tenant|
      ptt = tenant.property_tenants.this_month(period).first

      next if ptt.present?

      case tenant.payment_frequency
      when 'monthly'
        add_to_expected(tenant)
      when 'annually'
        add_to_expected(tenant) if tenant.start_date.month == period.month
      when 'bi-annually'
        add_to_expected(tenant) if tenant.start_date.month == period.month ||
            (tenant.start_date + 6.months).month == period.month
      when 'quarterly'
        add_to_expected(tenant) if tenant.start_date.month == period.month ||
            (tenant.start_date + 3.months).month == period.month ||
            (tenant.start_date + 6.months).month == period.month ||
            (tenant.start_date + 9.months).month == period.month
      end
    end
  end

  def add_to_expected(tenant)
    (tenant.day_of_month < Date.current.day) ? late << tenant : expected << tenant
  end
end