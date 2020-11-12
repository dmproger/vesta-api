class CreateTransactions < ActiveRecord::Migration[6.0]
  def change
    create_table :saved_transactions, id: :uuid do |t|
      t.decimal :amount
      t.string :category_id
      t.string :category_type
      t.date :transaction_date
      t.string :description
      t.string :transaction_id
      t.text :notes
      t.boolean :is_pending, default: false
      t.boolean :is_modified, default: false
      t.integer :user_defined_category
      t.index :user_defined_category

      t.references :user, type: :uuid
      t.references :account, type: :uuid
      t.timestamps
    end
  end
end
