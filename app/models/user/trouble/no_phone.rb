class User::Trouble::NoPhone < User::Agregator
  default_scope do
    User.where(phone: nil)
  end
end
