class Api::V1::UsersController < ApplicationController
  NOTIFICATION_PARAMS = %i[late_notification rent_notification].freeze
  PERSONAL_DATA_PARAMS = %i[name email phone first_name surname].freeze
  PARAMS_TO_UPDATE = PERSONAL_DATA_PARAMS + NOTIFICATION_PARAMS

  BOOLEAN = { 'true' => true, 'false' => false }

  VERIFICATION_TIMEOUT = 120 # seconds

  skip_before_action :authenticate_user!, only: [:verify_otp, :email_status, :phone_status]
  before_action :set_user, only: [:verify_otp]
  before_action :verify_user_id, only: :subscription_status

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
        current_user.notifications&.rental_payment
      elsif params[:type] == 'late'
        current_user.notifications&.late_payment
      else
        current_user.notifications.order(:created_at)
      end

    render json: { success: true, data: results }
  end

  def update
    update_profile_params
    return render json: @profile_error if @profile_error

    render json: { success: true, message: 'profile updated!', data: current_user.reload.attributes }
  end

  private

  def update_profile_params
    update_personal_data
    update_notification_config
  end

  def update_personal_data
    personal_params = params.permit(*PERSONAL_DATA_PARAMS)
    current_user.update!(personal_params) if personal_params.keys.any?
  end

  def update_notification_config
    update_late_notification_config if @params = params[:late_notification]
    update_rent_notification_config if @params = params[:rent_notification]
  end

  def update_late_notification_config
    late_notification_error
    return if @profile_error

    resolve_params_types
    @params = @params.permit(*User::LATE_NOTIFICATION_CONFIG.keys.map(&:to_sym))
    current_user.update! late_notification: current_user.late_notification.merge(@params)
  end

  def update_rent_notification_config
    rent_notification_error
    return if @profile_error

    resolve_params_types
    @params = @params.permit(*User::RENT_NOTIFICATION_CONFIG.keys.map(&:to_sym))
    current_user.update! rent_notification: current_user.rent_notification.merge(@params)
  end

  def late_notification_error
    @profile_error = { success: false, message: 'one of time/interval/enable must exists' } unless @params[:interval] || @params[:time] || @params[:enable].present?
    @profile_error = { success: false, message: 'incorrect param time, need 12:30 for example' } if @params[:time] && !/^\d\d:\d\d$/.match?(@params[:time])
    @profile_error = { success: false, message: 'incorrect param interval, need 3 for example' } if @params[:interval] && !/^\d{,3}$/.match?(@params[:interval])
    @profile_error = { success: false, message: 'incorrect param enable, need true or false' } if @params[:enable].present? && !/^(true)|(false)$/.match?(@params[:enable])
  end

  def rent_notification_error
    @profile_error = { success: false, message: 'enable must exists' } unless @params[:enable].present?
    @profile_error = { success: false, message: 'incorrect param enable, need true or false' } if @params[:enable].present? && !/^(true)|(false)$/.match?(@params[:enable])
  end

  def resolve_params_types
    @params[:enable] = BOOLEAN[@params[:enable]] if @params[:enable]
    @params[:interval] = @params[:interval].to_i if @params[:interval]
  end

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
