module Overrides
  class RegistrationsController < DeviseTokenAuth::RegistrationsController
    CREDENTIALS_PARAMS = %i[name email phone first_name surname].freeze

    skip_before_action :authenticate_user!

    def create
      create_params = sign_up_params.dup
      email = create_params.delete(:email)&.downcase

      @resource = params[:id] ? User.find(params[:id]) : User.new

      @resource.email     = email
      @resource.uid       = email
      @resource.password  = Devise.friendly_token.first(8)
      @resource.provider  = 'email'

      @resource.assign_attributes(create_params)
      @resource.save ? render_create_success : render_create_error
    end

    private

    def render_create_success
      render json: {
          success: true,
          message: 'Registered successfully',
          otp: @resource.otp_code,
          data: resource_data
      }
    end

    def render_create_error
      render json: {
          success: false,
          message: @resource.errors.to_h.map {|k,v| "#{k} #{v}"}.join(', '),
          data: resource_data,
      }, status: 422
    end
  end
end
