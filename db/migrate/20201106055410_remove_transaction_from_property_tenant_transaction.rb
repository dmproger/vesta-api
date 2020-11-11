class RemoveTransactionFromPropertyTenantTransaction < ActiveRecord::Migration[6.0]
  def change
    remove_reference :property_tenant_transactions, :saved_transaction
  end
end
