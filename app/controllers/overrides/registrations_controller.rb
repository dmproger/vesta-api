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
        Delayed::Job.enqueue SendOtpCode.new("Your Vesta OTP is: #{ @resource.otp_code }", @resource.phone)
        render_success
      else
        render_error
      end
    end

    def update
      @params = params[:notification]
      @notification = current_user.notification

      update_notification if @params
      return render json: @notification_error if @notification_error

      super
    end

    private

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

    def update_notification
      notification_type_error
      return if @notification_error

      send("#{ @params[:type] }_notification_error")
      return if @notification_error

      @config = @notification[@params[:type]]
      send("update_#{ @params[:type] }_notification_config")

      current_user.update!(notification: @notification.merge(@params[:type] => @config))
    end

    def update_late_notification_config
      @config.merge!('interval' => @params[:interval].to_i || @config[:interval])
      @config.merge!('time' => @params[:time] || @config[:time])
      @config.merge!('enable' => (@params[:enable].present? ? BOOLEAN[@params[:enable]] : @config[:enable]))
    end

    def update_rent_notification_config
      @config.merge!('enable' => (@params[:enable].present? ? BOOLEAN[@params[:enable]] : @config[:enable]))
    end

    def notification_type_error
      @notification_error = { success: false, message: 'incorrect param type' } unless @params[:type] && /(^late$)|(^income$)/.match?(@params[:type])
    end

    def late_notification_error
      @notification_error = { success: false, message: 'one of time/interval/enable must exists' } unless @params[:interval] || @params[:time] || @params[:enable].present?
      @notification_error = { success: false, message: 'incorrect param time, need 12:30 for example' } unless @params[:time] && /^\d\d:\d\d$/.match?(@params[:time])
      @notification_error = { success: false, message: 'incorrect param interval, need 3 for example' } unless @params[:interval] && /^\d{,3}$/.match?(@params[:interval])
      @notification_error = { success: false, message: 'incorrect param enable, need true or false' } unless @params[:enable] && /^(true)|(false)$/.match?(@params[:enable])
    end

    def rent_notification_error
      @notification_error = { success: false, message: 'incorrect param enable, need true or false' } unless @params[:enable] && /^(true)|(false)$/.match?(@params[:enable])
    end
  end
end
