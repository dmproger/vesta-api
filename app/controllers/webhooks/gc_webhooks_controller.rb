class Webhooks::GcWebhooksController < ApplicationController
  include ActionController::Live
  skip_before_action :authenticate_user!

  protect_from_forgery except: :create

  def create
    webhook_endpoint_secret = ENV['GC_WEBHOOK_SECRET']

    request_body = request.raw_post

    signature_header = request.headers['Webhook-Signature']

    begin
      events = GoCardlessPro::Webhook.parse(request_body: request_body,
                                            signature_header: signature_header,
                                            webhook_endpoint_secret: webhook_endpoint_secret)

      events.each do |event|
        response.stream.write("Processing event #{event.id}\n")

        case event.resource_type
        when 'mandates'
          Services::MandateEventProcessor.process(event, response)
        when 'subscriptions'
          Services::SubscriptionEventProcessor.process(event, response)
        when 'payments'
          Services::PaymentEventProcessor.process(event, response)
        else
          response.stream.write("Don't know how to process an event with resource_type " \
                              "#{event.resource_type}\n")
        end
      end

      response.stream.close
      render json: {success: true}, status: 200
    rescue GoCardlessPro::Webhook::InvalidSignatureError
      render status: 498, nothing: true
    end
  end
end
