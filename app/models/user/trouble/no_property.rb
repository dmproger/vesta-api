class User::Trouble::NoProperty < User::Agregator
  default_scope do
    User.where.not(id: User.joins(:properties).select(:id))
  end
end
