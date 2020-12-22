class CancelSubscription < Struct.new(:mandate)
  def perform
    user = User.find_by(mandate: mandate)
    return if user.blank?

    subscription = user.active_subscription
    return if subscription.blank?

    GoCardlessClient.new.cancel_subscription(external_sub_id: subscription.external_sub_id)
  end
end