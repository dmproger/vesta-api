class CreateJointTenants < ActiveRecord::Migration[6.0]
  def change
    create_table :joint_tenants, id: :uuid do |t|
      t.decimal :price
      t.integer :day_of_month
      t.string :name
      t.string :email
      t.string :phone

      t.references :tenant, type: :uuid
      t.timestamps
    end
  end
end
