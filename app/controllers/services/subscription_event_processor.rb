module Services
  class SubscriptionEventProcessor < Services::BaseService
    def self.process(event, response)
      case event.action
      when 'cancelled'
        response.stream.write("Subscription #{event.links.subscription} has been #{event.action}\n")

        return if gc_event(event.id).present?

        Delayed::Job.enqueue DelayedJobs::DeactivateSubscription.new(event.links.subscription)

        save_event(event)
      else
        response.stream.write("Don't know how to process a mandate #{event.action} " \
                            "event\n")
      end
    end
  end
end