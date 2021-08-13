class AddReportStateToSavedTransactions < ActiveRecord::Migration[6.0]
  def change
    add_column :saved_transactions, :report_state, :integer
  end
end
