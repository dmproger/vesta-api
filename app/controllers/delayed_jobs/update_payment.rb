module DelayedJobs
  class UpdatePayment < Struct.new(:payment)
    def perform
      ext_payment = GoCardlessClient.new.get_payment(payment_id: payment)
      return if ext_payment.blank?

      payment_in_db = Payment.find_by(payment_id: ext_payment.id)
      return if payment_in_db.blank?

      payment_in_db.update!(charge_date: ext_payment.charge_date,
                            description: ext_payment.description,
                            status: ext_payment.status)

    end
  end
end