class CreatePropertyTenantTransactions < ActiveRecord::Migration[6.0]
  def change
    create_table :property_tenant_transactions, id: :uuid do |t|
      t.references :property, type: :uuid
      t.references :tenant, type: :uuid
      t.references :saved_transaction, type: :uuid
      t.timestamps
    end
  end
end
