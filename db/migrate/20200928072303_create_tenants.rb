class CreateTenants < ActiveRecord::Migration[6.0]
  def change
    create_table :tenants, id: :uuid do |t|
      t.decimal :price
      t.string :payment_frequency, default: 'monthly'
      t.date :start_date
      t.date :end_date
      t.string :name
      t.string :email
      t.string :phone
      t.boolean :is_active, default: true
      t.boolean :agent_is_payee, default: false

      t.references :property, type: :uuid
      t.timestamps
    end
  end
end
