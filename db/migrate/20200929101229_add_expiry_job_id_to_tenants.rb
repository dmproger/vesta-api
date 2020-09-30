class AddExpiryJobIdToTenants < ActiveRecord::Migration[6.0]
  def change
    add_column :tenants, :expiry_job_id, :integer
  end
end
