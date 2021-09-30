return unless ENV['TINKTEST']

require 'rails_helper'
require_relative '../../../app/services/get_account_linking_code'

MODELS = [Account, TinkCredential, SavedTransaction]
require_relative '../../support/manual/test_user_data'

RSpec.describe Api::V1::AccountsController do
  let(:user) { USER }
  let(:account) { ACCOUNT_WITH_TRANSACTIONS }
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

  describe 'when PUT /api/v1/accounts/:id/update_credentials' do
    subject { put "/api/v1/accounts/#{ account.id }/update_credentials", params: params, headers: headers }

    it 'update credentials' do
      subject
    end
  end

  describe 'when POST /api/v1/accounts/:id/refresh_credentials' do
    subject { put "/api/v1/accounts/#{ account.id }/refresh_credentials", params: params, headers: headers }

    it 'update credentials' do
    end
  end
end
