class SavedTransaction < ApplicationRecord
  belongs_to :account
  belongs_to :user

  has_one :property_tenant_transaction

  has_one :property, through: :property_tenant_transaction,
           class_name: 'Property'

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
