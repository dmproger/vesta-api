class Api::V1::UsersController < ApplicationController
  BOOLEAN = { 'true' => true, 'false' => false }

  skip_before_action :authenticate_user!, only: [:verify_otp, :email_status, :phone_status]

  before_action :set_user, only: :verify_otp

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

  def notification_config
    case request.method
    when 'GET'
      return render json: { success: true, data: current_user.notification || User::DEFAULT_NOTIFICATION }
    when 'POST'
      return render json: { success: false, message: 'no type, interval and time params passed' } unless params[:type] && params[:interval] && params[:time] && params[:enable]
    when 'PATCH', 'PUT'
      return render json: { success: false, message: 'no type, interval or time params passed' } unless params[:type] || params[:interval] || params[:time] || params[:enable]
    when 'DELETE'
      current_user.update! notification: nil
      return render json: { success: true, message: 'notification disabled!' }
    end

    if %w[POST PATCH PUT].include?(request.method)
      return render json: { success: false, message: 'incorrect param time, need 12:30 for example' } unless params[:time] && /^\d\d:\d\d$/.match?(params[:time])
      return render json: { success: false, message: 'incorrect param interval, need 3 for example' } unless params[:interval] && /^\d\d?$/.match?(params[:interval])
      return render json: { success: false, message: 'incorrect param type, need late or income' } unless params[:type] && /(^late$)|(^income$)/.match?(params[:type])
      return render json: { success: false, message: 'incorrect param enable, need 1 or 0' } unless params[:enable] && /^(true)|(false)$/.match?(params[:enable])
    end

    config = current_user.notification&.send(:[], params[:type]) || {}

    config.merge!('interval' => params[:interval].to_i || config[:interval])
    config.merge!('time' => params[:time] || config[:time])
    config.merge!('enable' => BOOLEAN[params[:enable]] || config[:enable])

    current_user.update! notification: (current_user.notification || {}).merge(params[:type].to_sym => config)

    render json: { success: true, data: current_user.notification }
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
