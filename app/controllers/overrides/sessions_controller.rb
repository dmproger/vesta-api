module Overrides
  class SessionsController < DeviseTokenAuth::SessionsController
    skip_before_action :authenticate_user!

    def create
      find_resource(:phone, resource_params[:phone])
      if @resource.present?
        @resource.send_otp
        render json: {success: true, id: @resource.id, message: 'Please verify the OTP sent via SMS', otp: @resource.otp_code}
      else
        render json: {success: false, message: 'phone does not exist', data: nil}, status: 422
      end
    end
  end
end
