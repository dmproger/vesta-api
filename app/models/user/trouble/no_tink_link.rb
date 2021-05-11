class User::Trouble::NoTinkLink < User::Agregator
  default_scope do
    User.where(tink_user_id: nil)
  end
end
