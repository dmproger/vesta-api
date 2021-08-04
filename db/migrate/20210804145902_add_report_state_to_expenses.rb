class AddReportStateToExpenses < ActiveRecord::Migration[6.0]
  def change
    add_column :expenses, :report_state, :integer, null: false, default: 1
  end
end
