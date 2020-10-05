class CreateSubscriptions < ActiveRecord::Migration[6.0]
  def change
    create_table :subscriptions, id: :uuid do |t|
      t.string :interval_unit
      t.integer :day_of_month
      t.decimal :amount
      t.date :start_date
      t.boolean :is_active, default: false
      t.string :mandate
      t.string :customer
      t.string :external_sub_id
      t.string :currency
      t.string :month

      t.references :user, type: :uuid
      t.timestamps
    end
  end
end
