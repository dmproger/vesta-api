class CreateExpenses < ActiveRecord::Migration[6.0]
  def change
    create_table :expenses, id: :uuid do |t|
      t.uuid :user_id
      t.string :name

      t.timestamps
    end

    add_index :expenses, %i[user_id name], unique: true
  end
end
