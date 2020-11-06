class AssociatedTransaction < ApplicationRecord
  belongs_to :property_tenant
  belongs_to :joint_tenant, optional: true
  belongs_to :saved_transaction
end
