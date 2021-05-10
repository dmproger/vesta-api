class User::TinkNotRegistered < ActiveRecord::Base
  self.table_name = 'users'

  default_scope do
    User.where(tink_user_id: nil)
  end
end
