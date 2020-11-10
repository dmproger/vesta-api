class PropertyTenant < ApplicationRecord
  belongs_to :property
  belongs_to :tenant

  has_many :associated_transactions, dependent: :destroy
  has_many :saved_transactions, through: :associated_transactions

  scope :within, -> (period) {where(created_at: period.end_of_month..period.end_of_month)}
  scope :this_month, -> (period) {
    includes([:associated_transactions, :saved_transactions])
        .where(saved_transactions: {transaction_date: period.beginning_of_month..period.end_of_month})
  }
  scope :this_month_till_now, -> (period) {
    includes([:associated_transactions, :saved_transactions])
        .where(saved_transactions: {
            transaction_date: period.beginning_of_month..Date.parse("#{Date.current.day}-#{period.month}-#{period.year}")
        })
  }
end
