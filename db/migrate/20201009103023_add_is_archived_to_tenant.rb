class AddIsArchivedToTenant < ActiveRecord::Migration[6.0]
  def change
    add_column :tenants, :is_archived, :boolean, default: false
  end
end
