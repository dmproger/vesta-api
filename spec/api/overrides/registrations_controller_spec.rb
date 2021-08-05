require 'rails_helper'

RSpec.describe Overrides::RegistrationsController do
  context 'change user credentials' do
    subject { put '/api/v1/auth', headers: headers, params: params }

    def to_credentials(attributes)
      attributes.symbolize_keys.slice(*described_class::CREDENTIALS_PARAMS)
    end

    let!(:user) { create(:user) }
    let!(:credentials) { to_credentials(create(:user).attributes) }

    let!(:headers) { auth_headers }
    let!(:params) { { account_update: credentials } }

    before do
      sign_in(user)
    end

    it 'change user credentials' do
      pending

      expect(to_credentials(user.attributes)).not_to eq(credentials)

      subject

      expect(to_credentials(user.reload.attributes)).to eq(credentials)
    end
  end
end
