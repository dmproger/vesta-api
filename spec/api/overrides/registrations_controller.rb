require 'rails_helper'

ENV.delete('DO_NOT_SEND_SMS') if ENV['TWILLIO_TEST']

RSpec.describe Overrides::RegistrationsController do
  describe 'create user' do
    subject { post '/api/v1/auth/', headers: headers, params: params }

    let(:user) { build(:user, phone: ENV['TWILLIO_TEST_PHONE']) }
    let(:params) { user.attributes }
    let(:headers) { {} }

    it 'creates user' do
      expect { subject }.to change { User.count }.by(1)
      expect(user.phone).to eq(User.last.phone)
    end
  end
end
