class DefaultNotificationsConfigInUsers < ActiveRecord::Migration[6.0]
  def change
    change_column_default :users, :late_notification, from: nil, to: {}
    change_column_default :users, :rent_notification, from: nil, to: {}
  end
end
