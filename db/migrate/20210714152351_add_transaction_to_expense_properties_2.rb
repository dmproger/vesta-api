class AddTransactionToExpenseProperties2 < ActiveRecord::Migration[6.0]
  def change
    add_column :expense_properties, :saved_transaction_id, :uuid, null: false

    add_index :expense_properties,
      [:property_id, :expense_id, :saved_transaction_id],
      name: 'uniq_cortage_by_property_expense_transaction'
  end
end
