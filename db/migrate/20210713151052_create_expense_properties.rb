class CreateExpenseProperties < ActiveRecord::Migration[6.0]
  def change
    create_table :expense_properties, id: :uuid do |t|
      t.uuid :user_id
      t.uuid :expense_id
      t.uuid :property_id

      t.timestamps
    end

    add_index :expense_properties, [:user_id, :expense_id, :property_id], name: 'uniq_expense_property_user', unique: true
  end
end
