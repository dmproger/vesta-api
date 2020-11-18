class AddArchivedAtTimestampToPropertiesAndTenants < ActiveRecord::Migration[6.0]
  def change
    add_column :tenants, :archived_at, :date
    add_column :properties, :archived_at, :date
  end
end
