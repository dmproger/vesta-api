class Notification < ApplicationRecord
  DELIMITER = ';'

  belongs_to :user

  enum subject: {
    income_transactions: 0,
    rental_payment: 1
  }

  def self.rental_payment!(user, transactions)
    for transaction in transactions
      create!(
        user: user,
        subject: :rental_payment,
        title: 'Rental payment recived',
        text: "+#{ transaction.amount } from #{ transaction.description } (#{ transaction.property.address })"
      )
    end
  end
end
