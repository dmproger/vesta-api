return unless Rails.env.test?

[User, MODELS].flatten.each do |model|
  model.establish_connection(model.connection_config.merge(database: 'vesta_rails_development'))
end

USER = User.find_by(phone: '+447722222222')

ACCOUNT_WITH_TRANSACTIONS = USER.accounts.find_by(account_id: '2fcf3599c45d4088b18c2a4d5ba8f103')
ACCOUNT_WITHOUT_TRANSACTIONS = USER.accounts.find_by(account_id: 'a3ff1164c19b4342ac50b33451705322')
