class AddTinkColumnsToUser < ActiveRecord::Migration[6.0]
  def change
    add_column :users, :locale, :string
    add_column :users, :market, :string
    add_column :users, :tink_user_id, :string
    add_column :users, :tink_auth_code, :string
  end
end
