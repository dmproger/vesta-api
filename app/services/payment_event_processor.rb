class PaymentEventProcessor < BaseService
  def self.process(event, response)
    return if gc_event(event.id).present?

    case event.action
    when 'created'
      response.stream.write("Payment #{event.links.payment} has been #{event.action}\n")

      Delayed::Job.enqueue SavePayment.new(event.links.payment)

      save_event(event)
    when 'confirmed', 'submitted', 'paid_out', 'failed', 'canceled'
      response.stream.write("Payment #{event.links.payment} has been #{event.action}\n")

      Delayed::Job.enqueue UpdatePayment.new(event.links.payment)

      save_event(event)
    else
      response.stream.write("Don't know how to process a mandate #{event.action} " \
                            "event\n")
    end
  end
end
