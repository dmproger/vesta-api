class SendOtpCode < Struct.new(:text, :phone)
  def perform
    SendTwilioMessage.new(text, phone).call
  end
end
