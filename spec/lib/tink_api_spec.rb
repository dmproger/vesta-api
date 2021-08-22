return unless ENV['TINKTEST']

ENV['RAILS_ENV'] = 'development'

require 'rails_helper'
require_relative '../../app/tink_api/v1/client'

TEST_USER = User.find_by(phone: '+447722222222')

RSpec.describe TinkAPI::V1::Client do
  subject { described_class.new(token).send(method, **params) }

  let(:user) { TEST_USER }
  let(:token) { user.valid_tink_token(scopes: scopes) }

  describe 'auth code' do
    let(:auth_code) { GetAccountLinkingCode.new(user).call }
    let(:scopes) { 'transactions:read' }
    let(:method) { :retrieve_access_tokens }
    let(:params) do
      {
        auth_code: auth_code,
        scopes: scopes
      }
    end
 
    it 'account link code' do
      subject
      byebug
    end
  end

  describe '#transactions' do
    let(:scopes) { 'transactions:read' }
    let(:method) { :transactions }
    let(:params) do
      {
        account_id: user.accounts.sample.id,
        query_tag: ''
      }
    end

    it 'gets not empty transactions' do
      expect(subject[:results].any?).to be_truthy
    end
  end

  # describe '#new_transactions' do
    # let(:scopes) { 'transactions:read' }
    # let(:method) { :new_transactions }
    # let(:params) { {} }
#
    # it 'gets not empty transactions' do
      # expect(subject[:results].any?).to be_truthy
    # end
  # end
#
  # context '#retrieve_access_tokens' do
    # let(:scopes) { 'transactions:read' }
    # let(:method) { :new_transactions }
    # let(:params) { {} }
#
    # it 'gets not empty transactions' do
      # expect(subject[:results].any?).to be_truthy
    # end
  # end
end
