class CreateSubscriptions < ActiveRecord::Migration[6.0]
  def change
    create_table :subscriptions, id: :uuid do |t|
      t.string :payment_interval
      t.integer :day_of_month
      t.decimal :amount
      t.date :start_date
      t.boolean :is_active, default: false

      t.references :user, type: :uuid
      t.timestamps
    end
  end
end
