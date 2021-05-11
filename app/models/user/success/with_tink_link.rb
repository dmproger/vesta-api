class User::Success::WithTinkLink < User::Agregator
  default_scope do
    User.where.not(tink_user_id: nil)
  end
end
