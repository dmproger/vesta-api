class User::Success::WithProperty < User::Agregator
  default_scope do
    User.where(id: User.joins(:properties).pluck(:id))
  end
end
