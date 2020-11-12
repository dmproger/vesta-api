class AddAgentDataToTenant < ActiveRecord::Migration[6.0]
  def change
    add_column :tenants, :agent_name, :string
    add_column :tenants, :agent_email, :string
  end
end
