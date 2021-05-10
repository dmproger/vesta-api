class User::TenantNotAdded < ActiveRecord::Base
  # include Adminable

  self.table_name = 'users'

  default_scope do
    User.joins(:tenants).group(:id).having('count(user_id) = ?', 0).select('users.*')
  end
end
