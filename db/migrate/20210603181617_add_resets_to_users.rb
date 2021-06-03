class AddResetsToUsers < ActiveRecord::Migration[6.0]
  def change
    add_column :users, :reset_accounts, :boolean, default: false
    add_column :users, :reset_properties, :boolean, default: false
    add_column :users, :reset_tenants, :boolean, default: false
    add_column :users, :reset_transactions, :boolean, default: false
  end
end
