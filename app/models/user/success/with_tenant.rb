class User::Success::WithTenant < User::Agregator
  default_scope do
    User.where(id: User.joins(:tenants).pluck(:id))
  end
end
