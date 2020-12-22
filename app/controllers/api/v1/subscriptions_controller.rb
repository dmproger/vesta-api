class Api::V1::SubscriptionsController < ApplicationController
  before_action :set_subscription, only: [:show, :update, :destroy]
  skip_before_action :authenticate_user!, only: :complete_redirect_flow
  before_action :validate_subscription, only: :create

  def index
    @subscriptions = current_user.subscriptions
  end

  def show
    render json: {success: true, message: 'subscription', data: @subscription}
  end

  def create
    @subscription = current_user.subscriptions.create(subscription_params)

    if @subscription.persisted?
      if current_user.mandate.present?
        save_external_subscription(subscription: subscribe_user(current_user), user: current_user)
      else
        @redirect_flow = initiate_redirect_flow
      end
    else
      render json: {success: false, message: errors_to_string(@subscription), data: nil}
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
    cancel_subscription
    render json: {success: true, message: 'subscription canceled successfully', data: nil}
  rescue StandardError => e
    render json: {success: false, message: e.message, data: nil}
  end

  def complete_redirect_flow
    user = User.find_by(email: params[:session])
    redirect_flow = GoCardlessClient.new.complete_redirect_flow(flow_id: params.dig(:redirect_flow_id), user: user)
    if redirect_flow.links.present?
      save_customer_and_mandate(user, redirect_flow)
      save_external_subscription(subscription: subscribe_user(user), user: user)
      redirect_to 'ubps.vesta.test-goCardless://?completed=true' if redirect_flow.confirmation_url.present?
    else
      render json: {success: false, message: 'something went wrong', data: nil}
    end
  end

  private

  def cancel_subscription
    return false if @subscription.external_sub_id.blank?

    GoCardlessClient.new.cancel_subscription(external_sub_id: @subscription.external_sub_id)
  end

  def save_external_subscription(subscription:, user:)
    user.subscription.update(external_sub_id: subscription.id,
                             is_active: true,
                             month: subscription.month,
                             start_date: subscription.start_date,
                             day_of_month: subscription.day_of_month,
                             currency: subscription.currency)
  end

  def subscribe_user(user)
    GoCardlessClient.new.create_subscription(subscription: user.subscription, user: user)
  end

  def initiate_redirect_flow
    @redirect_flow = GoCardlessClient.new.create_redirect_flow(user: current_user, redirect_url: complete_redirect_flow_api_v1_subscriptions_url)
  end

  def validate_subscription
    render json: {success: false, message: 'you already have a valid subscription', data: nil} if current_user.active_subscription.present?
  end

  def save_customer_and_mandate(user, redirect_flow)
    user.update(mandate: redirect_flow.links.mandate,
                customer: redirect_flow.links.customer)
  end

  def set_subscription
    @subscription = current_user.subscriptions.find_by(id: params[:id])
    if @subscription.blank?
      render json: {success: false, message: 'invalid subscription id', data: nil}
    end
  end

  def subscription_params
    params.require(:subscription).permit(:interval_unit, :amount, :month, :currency, :day_of_month)
  end
end
