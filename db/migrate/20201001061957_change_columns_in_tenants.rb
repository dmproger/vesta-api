class ChangeColumnsInTenants < ActiveRecord::Migration[6.0]
  def change
    remove_column :tenants, :agent_is_payee
    add_column :tenants, :payee_type, :string, default: 'tenant'
  end
end
