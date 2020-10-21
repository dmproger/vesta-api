class SavedTransaction < ApplicationRecord
  belongs_to :account
  belongs_to :user

  has_many :property_tenant_transactions

  has_many :properties, through: :property_tenant_transactions,
           class_name: 'Property'

  enum user_defined_category: [:rent, :mortgage, :ground_rent, :other]
end
