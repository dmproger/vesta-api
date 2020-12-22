class AddIsArchivedToProperty < ActiveRecord::Migration[6.0]
  def change
    add_column :properties, :is_archived, :boolean, default: false
  end
end
