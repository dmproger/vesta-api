return unless ENV['TINKTEST']

require 'rails_helper'
require_relative '../../../app/services/get_account_linking_code'

[User, Account, TinkCredential].each do |model|
  model.establish_connection(
    model.connection_config.merge(database: 'vesta_rails_development')
  )
end
TEST_USER = User.find_by(phone: '+447722222222')
ACCOUNT_WITH_TRANSACTIONS = '2fcf3599c45d4088b18c2a4d5ba8f103'
ACCOUNT_WITHOUT_TRANSACTIONS = 'a3ff1164c19b4342ac50b33451705322'

RSpec.describe Api::V1::AccountsController do
  let(:user) { TEST_USER }
  let(:account) { Account.find_by(account_id: ACCOUNT_WITH_TRANSACTIONS) }
  let(:headers) { auth_headers(user) }
  let(:params) do
    {
      callback_url: 'ru.test.vesta-tinkRenew://'
    }
  end

  let(:data) { JSON.parse(body)['data'] }

  before { sign_in(user) }

  describe 'when GET /api/v1/accounts/:id/renew_credentials_link' do
    subject { get "/api/v1/accounts/#{ account.id }/renew_credentials_link", params: params, headers: headers }

    it 'gets correct renew link' do
      subject
    end
  end

  describe 'when POST /api/v1/accounts/update_credentials' do
    subject { post '/api/v1/accounts/renew_credentials_link', params: params, headers: headers }

  end
end
