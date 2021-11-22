class Api::V1::UsersController < ApplicationController
  BOOLEAN = { 'true' => true, 'false' => false }

  skip_before_action :authenticate_user!, only: [:verify_otp, :email_status, :phone_status]

  before_action :set_user, only: [:verify_otp, :notifications]

  before_action :verify_user_id, only: :subscription_status

  VERIFICATION_TIMEOUT = 120 # seconds
  def verify_otp
    if @resource.authenticate_otp(params.dig( :otp).to_s, drift: VERIFICATION_TIMEOUT)
      sign_in_user
      render json: {success: true, message: 'OTP successfully verified', data: @resource.token_validation_response}
    else
      render json: {success: false, message: 'invalid OTP, please try again', data: nil}
    end
  end

  def details
    render json: {success: true, data: current_user}
  end

  def email_status
    is_taken = User.find_by(email: params[:email]).present?
    render json: {success: true, message: 'email status', taken: is_taken}
  end

  def phone_status
    is_taken = User.find_by(phone: params[:phone]).present?
    render json: {success: true, message: 'phone status', taken: is_taken}
  end

  def subscription_status
    render json: {
      status: true,
      message: 'subscription status',
      data: {
        active_subscription: current_user.active_subscription.present?
      }
    }
  end

  def notifications
    results =
      if params[:type] == 'rent'
        @resource.notifications&.rental_payment
      elsif params[:type] == 'late'
        @resource.notifications&.late_payment
      else
        @resource.notifications.order(:created_at)
      end

    render json: { success: true, data: results }
  end

  private

  def verify_user_id
    render json: {
      success: false,
      message: 'invalid user, please login and try again',
      data: nil
    } unless current_user.id == params[:id]
  end

  def sign_in_user
    @token = @resource.create_token
    @resource.save
    sign_in(:user, @resource, store: false, bypass: false)
  end

  def set_user
    @resource = User.find_by(id: params[:id])
    if @resource.blank?
      render json: {success: false, message: 'invalid user id', data: nil}
    end
  end
end
