class User::PhoneNotConfirmed < ActiveRecord::Base
  self.table_name = 'users'

  default_scope do
    User.where(phone: nil)
  end
end
