class SendOtpJob < ApplicationJob
  def perform(message, phone)
    SendTwilioMessage.new(message, phone).call
  end
end
