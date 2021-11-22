class Notification < ApplicationRecord
  belongs_to :user

  enum subject: {
    income_transactions: 0,
    rental_payment: 1,
    late_payment: 2
  }

  def self.rental_payment!(user, transactions)
    for transaction in transactions
      next unless transaction.property

      create!(
        user: user,
        subject: :rental_payment,
        title: 'Rental payment recived',
        text: "+#{ transaction.amount } from #{ transaction.description } (#{ transaction.property.address })"
      )
    end
  end

  def self.late_payment!(user, property)
  end
end
