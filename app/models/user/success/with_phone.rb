class User::Success::WithPhone < User::Agregator
  default_scope do
    User.where.not(phone: nil)
  end
end
