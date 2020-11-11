class AddProcessedColumnsToSavedTransactions < ActiveRecord::Migration[6.0]
  def change
    add_column :saved_transactions, :is_processed, :boolean, default: false
    add_column :saved_transactions, :is_associated, :boolean, default: false
    add_column :saved_transactions, :association_type, :integer
  end
end
