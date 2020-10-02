class Api::V1::SubscriptionsController < ApplicationController
  before_action :set_subscription, only: [:show, :update, :destroy]
  skip_before_action :authenticate_user!, only: :complete_redirect_flow

  def index
    @subscriptions = current_user.subscriptions
  end

  def show
    render json: {success: true, message: 'subscription', data: @subscription}
  end

  def create
    subscription = current_user.subscriptions.create(subscription_params)

    if subscription.persisted?
      render json: {success: true, message: 'created successfully', data: subscription}
    else
      render json: {success: false, message: errors_to_string(subscription), data: nil}
    end
  end

  def update
    if @subscription.update(subscription_params)
      render json: {success: true, message: 'updated successfully', data: @subscription}
    else
      render json: {success: false, message: errors_to_string(@subscription), data: nil}
    end
  end

  def destroy
    @subscription.destroy
    render json: {success: true, message: 'deleted successfully', data: nil}
  rescue StandardError => e
    render json: {success: false, message: e.message, data: nil}
  end

  def initiate_redirect_flow
    @redirect_flow = GoCardlessClient.new.create_redirect_flow(user: current_user, redirect_url: complete_redirect_flow_api_v1_subscriptions_url)
  end

  def complete_redirect_flow
    user = User.find_by(email: params[:session])
    redirect_flow = GoCardlessClient.new.complete_redirect_flow(flow_id: params.dig(:redirect_flow_id), user: user)
    render json: {success: true, message: 'flow completed', data: redirect_flow}
  end

  private

  def set_subscription
    @subscription = current_user.subscriptions.find_by(id: params[:id])
    if @subscription.blank?
      render json: {success: false, message: 'invalid subscription id', data: nil}
    end
  end

  def subscription_params
    params.require(:subscription).permit(:payment_interval, :day_of_month, :amount, :start_date)
  end
end
