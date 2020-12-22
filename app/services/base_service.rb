class BaseService
  def self.save_event(event)
    user = User.find_by(mandate: event.links.mandate)
    user.gc_events.create(gc_event_id: event.id)
  end

  def self.gc_event(event_id)
    GcEvent.find_by(gc_event_id: event_id)
  end
end
