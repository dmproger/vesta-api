class SendTwilioMessage
  attr_reader :message, :to

  def initialize(message, to)
    @message = message
    @to = to
  end

  def call
    return if ENV['DO_NOT_SEND_SMS']

    client = Twilio::REST::Client.new(ENV['TWILLIO_ACCOUNT_SID'], ENV['TWILLIO_AUTH_TOKEN'])
    client.messages.create(body: message, to: to, from: ENV['TWILLIO_FROM_NUMBER'])
  end
end
