module Overrides
  class RegistrationsController < DeviseTokenAuth::RegistrationsController
    skip_before_action :authenticate_user!

    def create
      create_params = sign_up_params.dup
      email = create_params.delete(:email)&.downcase
      @resource = User.new(email: email, uid: email,
                           password: Devise.friendly_token.first(8),
                           provider: 'email')
      @resource.assign_attributes(create_params)
      @resource.save ? render_create_success : render_create_error
    end

    private

    def render_create_success
      render json: {
          success: true,
          message: 'Registered successfully',
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
