class CreatePayments < ActiveRecord::Migration[6.0]
  def change
    create_table :payments, id: :uuid do |t|
      t.string :payment_id
      t.date :charge_date
      t.string :description
      t.string :status

      t.references :subscription, type: :uuid
      t.timestamps
    end
  end
end
