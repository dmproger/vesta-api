class Api::V1::HomeController < ApplicationController
  before_action :set_period
  before_action :set_type, only: :details

  def index
    @data = if params[:test] == 'true'
              HomeTestData.new(period: @period).call
            else
              HomeData.new(period: @period, current_user: current_user).call
            end
  end

  def details
    details = HomeDataDetails.new(period: @period, type: params[:type], current_user: current_user).call
    render json: {success: true, message: 'home details', data: {
        type: params[:type],
        details: details.as_json(include: [:property, :tenant, :saved_transaction])
    }}
  end

  private

  def set_type
    unless %w[collected expected late].include? params[:type]
      render json: {success: false, message: 'invalid type', data: nil}
    end
  end

  def set_period
    @period = Date.parse("01-#{params[:period]}")
  end
end
