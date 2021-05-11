class User::Success::WithBankAccount < User::Agregator
  default_scope do
    User.where(id: User.joins(:accounts).pluck(:id))
  end
end
