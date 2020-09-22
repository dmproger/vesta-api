class Api::V1::UsersController < ApplicationController


  VERIFICATION_TIMEOUT = 120 # seconds
  def verify_otp
    # TODO: verify the OTP and update phone verified flag
    render json: {success: true, message: 'OTP successfully verified'}
  end
end
