class SendTwilioMessage
  attr_reader :message, :to

  def initialize(message, to)
    @message = message
    @to = to
  end

  def call
    return if ENV['DO_NOT_SEND_SMS'].present?

    client = Twilio::REST::Client.new
    client.messages.create(body: message, to: to, from: ENV['TWILIO_FROM_NUMBER'])
  end
end
