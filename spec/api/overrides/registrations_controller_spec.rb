require 'rails_helper'

RSpec.describe Overrides::RegistrationsController do
  context 'change user credentials' do
    subject(:change_credentials) { put '/api/v1/auth', headers: headers, params: params }

    def to_credentials(attributes)
      attributes.symbolize_keys.slice(*described_class::CREDENTIALS_PARAMS)
    end

    let!(:user) { create(:user) }
    let!(:some_user) { create(:user) }
    let!(:credentials) { to_credentials(some_user.attributes) }

    let!(:headers) { auth_headers }
    let!(:params) { {}.merge(registration: credentials) }

    before do
      some_user.delete
      sign_in(user)
    end

    it 'change user credentials' do
      change_credentials

      expect(to_credentials(user.attributes)).not_to eq(credentials)
      expect(to_credentials(user.reload.attributes)).to eq(credentials)
    end
  end
end
