class AssociatedTransaction < ApplicationRecord
  belongs_to :property_tenant
  belongs_to :joint_tenant, optional: true
  belongs_to :saved_transaction

  has_one :property, through: :property_tenant
  has_one :tenant, through: :property_tenant

  scope :within, -> (period) {includes(:saved_transaction).where(saved_transactions: {transaction_date: period.beginning_of_month..period.end_of_month})}
end
