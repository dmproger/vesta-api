class Api::V1::UsersController < ApplicationController

  skip_before_action :authenticate_user!, only: [:verify_otp]

  before_action :set_user, only: :verify_otp

  VERIFICATION_TIMEOUT = 120 # seconds
  def verify_otp
    if @resource.authenticate_otp(params.dig( :otp).to_s, drift: VERIFICATION_TIMEOUT)
      sign_in_user
      render json: {success: true, message: 'OTP successfully verified', data: @resource.token_validation_response}
    else
      render json: {success: false, message: 'invalid OTP, please try again'}
    end
  end

  private

  def sign_in_user
    @token = @resource.create_token
    @resource.save
    sign_in(:user, @resource, store: false, bypass: false)
  end

  def set_user
    @resource = User.find_by(id: params[:id])
    if @resource.blank?
      render json: {success: false, message: 'invalid user id'}
    end
  end

  def render_create_success
    render json: {
        data: resource_data(resource_json: @resource.token_validation_response)
    }
  end
end
