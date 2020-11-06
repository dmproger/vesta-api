class ChangePropertyTenantTransactionTableName < ActiveRecord::Migration[6.0]
  def change
    rename_table :property_tenant_transactions, :property_tenants
  end
end
