class User::Success::WithPhoneConfirmed < User::Agregator
  default_scope do
    User.where(phone_verified: true)
  end
end
