class SavedTransaction < ApplicationRecord
  belongs_to :account
  belongs_to :user

  scope :within, -> (period) {where(transaction_date: period.beginning_of_month..period.end_of_month)}
  scope :income, -> {where(category_type: 'INCOME')}

  has_one :property_tenant_transaction

  has_one :property, through: :property_tenant_transaction,
           class_name: 'Property'

  has_one :tenant, through: :property_tenant_transaction,
          class_name: 'Tenant'

  enum user_defined_category: [:rent, :mortgage, :ground_rent, :other]

  def replace_property(attributes = nil)
    PropertyTenantTransaction.transaction do
      property_tenant_transaction&.destroy!
      create_property_tenant_transaction!(attributes)
    end
  rescue ActiveRecord::RecordInvalid, ActiveRecord::RecordNotDestroyed
    property_tenant_transaction
  end
end
