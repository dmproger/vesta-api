class User::Trouble::NoTenant < User::Agregator
  default_scope do
    User.where.not(id: User.joins(:tenants).select(:id))
  end
end
