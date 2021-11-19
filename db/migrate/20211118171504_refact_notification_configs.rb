class RefactNotificationConfigs < ActiveRecord::Migration[6.0]
  def change
    remove_column :users, :notification

    add_column :users, :late_notification, :jsonb, default: nil
    add_column :users, :rent_notification, :jsonb, default: nil
  end
end
