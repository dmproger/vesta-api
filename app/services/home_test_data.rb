class HomeTestData
  attr_reader :period,
              :expected, :collected, :total, :late

  MAX_BALANCE = 100_000

  def initialize(period:)
    @period = period
  end

  def call
    @total = @expected = rand(MAX_BALANCE)
    @collected = rand(total)
    @late = rand(total - collected)
    @expected = @expected - late - collected

    [total, collected, expected, late]
  end
end