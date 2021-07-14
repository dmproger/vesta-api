class RemoveTransactionColumnInExpenseProperties < ActiveRecord::Migration[6.0]
  def change
    remove_column :expense_properties, :transaction_id, :saved_transaction_id
  end
end
