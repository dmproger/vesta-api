class User::Trouble::NoPhoneConfirmed < User::Agregator
  default_scope do
    User.where(phone_verified: false)
  end
end
