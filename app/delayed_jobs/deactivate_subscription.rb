class DeactivateSubscription < Struct.new(:subscription)
  def perform
    active_sub = Subscription.active.find_by(external_sub_id: subscription)
    return if active_sub.blank?

    active_sub.update(is_active: false)
  end
end