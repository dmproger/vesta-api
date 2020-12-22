class SavePayment < Struct.new(:payment)
  def perform
    ext_payment = GoCardlessClient.new.get_payment(payment_id: payment)
    return if ext_payment.blank?

    subscription = Subscription.find_by(external_sub_id: ext_payment.links.subscription)
    return if subscription.blank?

    return if subscription.payments.find_by(payment_id: ext_payment.id).present?

    subscription.payments.create!(payment_id: ext_payment.id,
                                  charge_date: ext_payment.charge_date,
                                  description: ext_payment.description,
                                  status: ext_payment.status)

  end
end
