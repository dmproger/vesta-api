module Overrides
  class SessionsController < DeviseTokenAuth::SessionsController
    skip_before_action :authenticate_user!

    def create
      find_resource(:phone, resource_params[:phone])
      if @resource.present?
        @resource.send_otp
        render json: {success: true, id: @resource.id, message: 'Please verify the OTP sent via SMS'}
      else
        render_create_error_bad_credentials
      end
    end
  end
end
