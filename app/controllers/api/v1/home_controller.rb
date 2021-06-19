class Api::V1::HomeController < ApplicationController
  before_action :set_period
  before_action :set_type, only: [:details]

  def index
    @data = if params[:test] == 'true'
              HomeTestData.new(period: @period).call
            else
              HomeData.new(period: @period, current_user: current_user).call
            end
  end

  def summary
    sum = current_user.saved_transactions.joins(:associated_transactions).where.not(id: nil).sum(:amount)

    render json: { success: true, message: params[:type], data: sum }
  end

  def all_data
    @data = HomeData.new(period: @period, current_user: current_user).call

    @associated_transactions = current_user.associated_transactions.within(@period)

    @expected_tenants, @late_tenants = ExpectedAmountDetail.new(period: @period,
                                                                current_user: current_user,
                                                                type: 'all').call
  end

  def collected
    @associated_transactions = current_user.associated_transactions.within(@period)
  end

  # expected and late tenants details
  def details
    tenants = ExpectedAmountDetail.new(period: @period, current_user: current_user, type: params[:type]).call

    render json: {success: true, message: params[:type], data: tenants}
  end

  private

  def set_type
    unless %w[expected late].include? params[:type]
      render json: {success: false, message: 'invalid type', data: nil}
    end
  end

  def set_period
    @period = Date.parse("01-#{params[:period]}")
  end
end
