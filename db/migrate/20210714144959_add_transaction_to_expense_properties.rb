class AddTransactionToExpenseProperties < ActiveRecord::Migration[6.0]
  def change
    remove_index :expense_properties, name: 'uniq_expense_property_user'

    remove_column :expense_properties, :user_id

    change_column_null(:expense_properties, :expense_id, false)
    change_column_null(:expense_properties, :property_id, false)

    add_column :expense_properties, :transaction_id, :uuid, default: false

    add_index :expense_properties, [:property_id, :expense_id, :transaction_id],
      name: 'uniq_cortage_by_property_expense_transaction',
      unique: true
  end
end
