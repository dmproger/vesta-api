return unless ENV['TINKTEST']

require 'rails_helper'
require_relative '../../app/tink_api/v1/client'

MODELS = [Account, TinkCredential, SavedTransaction]
require_relative '../support/manual/test_user_data'

RSpec.describe TinkAPI::V1::Client do
  subject { described_class.new(token).send(method, **params) }

  let(:user) { USER }
  let(:token) { user.valid_tink_token(scopes: scopes) }
  let(:account) { ACCOUNT_WITH_TRANSACTIONS }

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
      subject
      # expect(subject[:accounts].any?).to be_truthy
    end
  end

  describe '#refresh_credentials' do
    let(:scopes) { 'credentials:refresh' }
    let(:method) { :refresh_credentials }
    let(:tink_credential) { account.tink_credential }
    let(:params) { { id: tink_credential.credentials_id } }

    it 'returns accounts' do
      # byebug
    end
  end
end
