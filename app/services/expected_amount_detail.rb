class ExpectedAmountDetail < HomeUtils
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

    if type == 'all'
      [expected, late]
    else
      (type == 'expected') ? expected : late
    end
  end

  private

  def evaluate_expected_detail
    current_user.non_archived_tenants_by(period: period).within(period).each do |tenant|
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
    if get_due_datetime(period + (tenant.day_of_month - 1)) < DateTime.current
      late << tenant.as_json(include: :joint_tenants)
    else
      expected << tenant.as_json(include: :joint_tenants)
    end
  end
end