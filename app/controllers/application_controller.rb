class ApplicationController < ActionController::Base
  skip_before_action :verify_authenticity_token
  include DeviseTokenAuth::Concerns::SetUserByToken

  before_action :authenticate_user!

  protect_from_forgery with: :null_session

  before_action :configure_permitted_parameters, if: :devise_controller?

  protected

  def configure_permitted_parameters
    attributes = [:first_name, :surname, :phone, :email, :password, :password_confirmation, :no_otp, :apns_token]
    devise_parameter_sanitizer.permit(:sign_up, keys: attributes)
    devise_parameter_sanitizer.permit(:sign_in, keys: attributes)
    devise_parameter_sanitizer.permit(:account_update, keys: attributes)
  end

  def errors_to_string(object)
    object.errors.to_h.map {|k,v| "#{k} #{v}"}.join(', ')
  end
end
