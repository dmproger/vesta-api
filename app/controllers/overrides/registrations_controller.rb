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
      update_notification if @notification = params[:notification]
      return if @notification_error

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
      return render json: @notification_error if @notification_error

      @config = current_user.notification[@notification[:type]]

      send("update_#{ @notification[:type] }_notification")
    end

    def update_late_notification
      late_notification_errors
      return render json: @notification_error if @notification_error

      @config.merge!('interval' => @notification[:interval].to_i || @config[:interval])
      @config.merge!('time' => @notification[:time] || @config[:time])
      @config.merge!('enable' => (@notification[:enable].present? ? BOOLEAN[@notification[:enable]] : @config[:enable]))

      current_user.update! notification: { 'late' => @config }
    end

    def update_rent_notification
    end

    def notification_type_error
      @notification_error = { success: false, message: 'incorrect param type' } unless @notification[:type] && /(^late$)|(^income$)/.match?(@notification[:type])
    end

    def late_notification_errors
      @notification_error = { success: false, message: 'one of time/interval/enable must exists' } unless @notification[:interval] || @notification[:time] || @notification[:enable]
      @notification_error = { success: false, message: 'incorrect param time, need 12:30 for example' } unless @notification[:time] && /^\d\d:\d\d$/.match?(@notification[:time])
      @notification_error = { success: false, message: 'incorrect param interval, need 3 for example' } unless @notification[:interval] && /^\d\d?$/.match?(@notification[:interval])
      @notification_error = { success: false, message: 'incorrect param enable, need 1 or 0' } unless @notification[:enable] && /^(true)|(false)$/.match?(@notification[:enable])
    end
  end
end
