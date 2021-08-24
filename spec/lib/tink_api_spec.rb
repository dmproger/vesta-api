return unless ENV['TINKTEST']

require 'rails_helper'
require_relative '../../app/tink_api/v1/client'

[User, Account, TinkCredential].each do |model|
  model.establish_connection(
    model.connection_config.merge(database: 'vesta_rails_development')
  )
end
TEST_USER = User.find_by(phone: '+447722222222')
ACCOUNT_WITH_TRANSACTIONS = '2fcf3599c45d4088b18c2a4d5ba8f103'
ACCOUNT_WITHOUT_TRANSACTIONS = 'a3ff1164c19b4342ac50b33451705322'

RSpec.describe TinkAPI::V1::Client do
  subject { described_class.new(token).send(method, **params) }

  let(:user) { TEST_USER }
  let(:token) { user.valid_tink_token(scopes: scopes) }
  let(:account) { user.accounts.find_by(account_id: ACCOUNT_WITH_TRANSACTIONS) }

  describe '#transactions' do
    let(:scopes) { 'transactions:read' }
    let(:method) { :transactions }
    let(:params) do
      {
        account_id: account.account_id,
        query_tag: ''
      }
    end

    it 'gets not empty transactions' do
      expect(subject[:results].any?).to be_truthy
    end
  end

  describe '#accounts' do
    let(:scopes) { 'accounts:read' }
    let(:method) { :accounts }
    let(:params) { {} }

    it 'returns accounts' do
      expect(subject[:accounts].any?).to be_truthy
    end
  end

  describe '#get_credentials' do
    let(:scopes) { 'credentials:read' }
    let(:method) { :get_credentials }
    let(:tink_credential) { account.tink_credential }
    let(:params) { { id: tink_credential.credentials_id } }

    it 'returns accounts' do
      expect(subject[:accounts].any?).to be_truthy
    end
  end
end
