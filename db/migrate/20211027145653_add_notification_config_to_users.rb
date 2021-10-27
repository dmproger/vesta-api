class AddNotificationConfigToUsers < ActiveRecord::Migration[6.0]
  def change
    add_column :users, :notification, :jsonb
  end
end
