class MandateEventProcessor < BaseService
  def self.process(event, response)
    case event.action
    when 'cancelled', 'expired'
      response.stream.write("Mandate #{event.links.mandate} has been #{event.action}\n")

      return if gc_event(event.id).present?

      Delayed::Job.enqueue CancelSubscription.new(event.links.mandate)

      save_event(event)
    else
      response.stream.write("Don't know how to process a mandate #{event.action} " \
                            "event\n")
    end
  end
end

