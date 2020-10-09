class CreateAddresses < ActiveRecord::Migration[6.0]
  def change
    create_table :addresses, id: :uuid do |t|
      t.text :address
      t.string :city
      t.string :post_code
      t.string :country

      t.references :user, type: :uuid
      t.timestamps
    end
  end
end
