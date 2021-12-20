module Overrides
  class RegistrationsController < DeviseTokenAuth::RegistrationsController
    CREDENTIALS_PARAMS = %i[name email phone first_name surname notification].freeze
    BOOLEAN = { 'true' => true, 'false' => false }

    skip_before_action :authenticate_user!, only: [:create]

    def create
      create_params = sign_up_params.dup
      email = create_params.delete(:email)&.downcase
      @resource = User.new(email: email, uid: email,
                           password: Devise.friendly_token.first(8),
                           provider: 'email')
      @resource.assign_attributes(create_params)

      if @resource.save
        @resource.send_otp
        render_success
      else
        render_error
      end
    end

    def render_success
      render json: {
          success: true,
          message: 'Registered successfully',
          otp: @resource.otp_code,
          data: resource_data
      }
    end

    def render_error
      render json: {
          success: false,
          message: @resource.errors.to_h.map {|k,v| "#{k} #{v}"}.join(', '),
          data: resource_data,
      }, status: 422
    end
  end
end
