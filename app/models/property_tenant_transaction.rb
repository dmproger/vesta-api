class PropertyTenantTransaction < ApplicationRecord
  belongs_to :property
  belongs_to :tenant
  belongs_to :saved_transaction

  scope :this_month, -> (period) {includes(:saved_transaction).where(saved_transactions: {transaction_date: period.beginning_of_month..period.end_of_month})}
  scope :this_month_till_now, -> (period) {includes(:saved_transaction).where(saved_transactions: {transaction_date: period.beginning_of_month..Date.parse("#{Date.current.day}-#{period.month}-#{period.year}")})}
end
