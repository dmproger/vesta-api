class User::TinkRegistered < ActiveRecord::Base
  self.table_name = 'users'

  default_scope do
    User.where.not(tink_user_id: nil)
  end
end
