class User::Trouble::NoBankAccount < User::Agregator
  default_scope do
    User.where.not(id: User.joins(:accounts).select(:id))
  end
end
