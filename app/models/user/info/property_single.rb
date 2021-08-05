class User::Info::PropertySingle < ActiveRecord::Base
  # include Adminable

  self.table_name = 'users'

  default_scope do
    User.joins(:properties).group(:id).having('count(user_id) = ?', 1).select('users.*')
  end
end
