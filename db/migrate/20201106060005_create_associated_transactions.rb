class CreateAssociatedTransactions < ActiveRecord::Migration[6.0]
  def change
    create_table :associated_transactions, id: :uuid do |t|
      t.references :property_tenant, type: :uuid
      t.references :saved_transaction, type: :uuid
      t.references :joint_tenant, type: :uuid, required: false
      t.timestamps
    end
  end
end
