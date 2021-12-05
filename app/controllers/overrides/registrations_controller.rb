module Overrides
  class RegistrationsController < DeviseTokenAuth::RegistrationsController
    PARAMS_TO_UPDATE = %w[name email phone first_name surname late_notification rent_notification].freeze
    BOOLEAN = { 'true' => true, 'false' => false }

    skip_before_action :authenticate_user!, only: [:create]
    before_action :authenticate_user!, only: [:update]

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

    def update
      if current_user
        update_notification_config
        return render json: @notification_error if @notification_error
      end
      super
    end

    private

    def render_success(*args)
      render json: {
          success: true,
          message: 'Registered successfully',
          otp: @resource.otp_code,
          data: resource_data
      }
    end

    def render_error(*args)
      render json: {
          success: false,
          message: @resource.errors.to_h.map {|k,v| "#{k} #{v}"}.join(', '),
          data: resource_data,
      }, status: 422
    end

    def update_notification_config
      update_late_notification_config if @params = params[:late_notification]&.permit(%i[enable time interval])
      update_rent_notification_config if @params = params[:rent_notification]&.permit(%i[enable])
    end

    def update_late_notification_config
      late_notification_error
      return if @notification_error

      resolve_params_types
      current_user.update! late_notification: current_user.late_notification.merge(@params)
    end

    def update_rent_notification_config
      rent_notification_error
      return if @notification_error

      resolve_params_types
      current_user.update! rent_notification: current_user.rent_notification.merge(@params)
    end

    def late_notification_error
      @notification_error = { success: false, message: 'one of time/interval/enable must exists' } unless @params[:interval] || @params[:time] || @params[:enable].present?
      @notification_error = { success: false, message: 'incorrect param time, need 12:30 for example' } if @params[:time] && !/^\d\d:\d\d$/.match?(@params[:time])
      @notification_error = { success: false, message: 'incorrect param interval, need 3 for example' } if @params[:interval] && !/^\d{,3}$/.match?(@params[:interval])
      @notification_error = { success: false, message: 'incorrect param enable, need true or false' } if @params[:enable].present? && !/^(true)|(false)$/.match?(@params[:enable])
    end

    def rent_notification_error
      @notification_error = { success: false, message: 'enable must exists' } unless @params[:enable].present?
      @notification_error = { success: false, message: 'incorrect param enable, need true or false' } if @params[:enable].present? && !/^(true)|(false)$/.match?(@params[:enable])
    end

    def resolve_params_types
      @params[:enable] = BOOLEAN[@params[:enable]] if @params[:enable]
      @params[:interval] = @params[:interval].to_i if @params[:interval]
    end
  end
end
