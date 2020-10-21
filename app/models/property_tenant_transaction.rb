class PropertyTenantTransaction < ApplicationRecord
  belongs_to :property
  belongs_to :tenant
  belongs_to :saved_transaction
end
