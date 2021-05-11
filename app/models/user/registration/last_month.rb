class User::Registration::LastMonth < User::Agregator
  default_scope do
    User.where(created_at: [])
  end
end
