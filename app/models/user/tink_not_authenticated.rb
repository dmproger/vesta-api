class User::TinkNotAuthenticated < ActiveRecord::Base
  self.table_name = 'users'

  default_scope do
    User.where.not(tink_user_id: nil).where(tink_auth_code: nil)
  end
end
