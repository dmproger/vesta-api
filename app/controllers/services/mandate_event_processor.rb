module Services
  class MandateEventProcessor
    def self.process(event, response)
      case event.action
      when 'cancelled', 'expired'
        response.stream.write("Mandate #{event.links.mandate} has been #{event.action}\n")

        return if GcEvent.find_by(gc_event_id: event.id).present?

        Delayed::Job.enqueue DelayedJobs::CancelSubscription.new(event.links.mandate)

        save_event(event)
      else
        response.stream.write("Don't know how to process a mandate #{event.action} " \
                            "event\n")
      end
    end

    private

    def self.save_event(event)
      user = User.find_by(mandate: event.links.mandate)
      user.gc_events.create(gc_event_id: event.id)
    end
  end
end
