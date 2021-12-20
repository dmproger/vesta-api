require 'rails_helper'

RSpec.describe Overrides::RegistrationsController do
  describe 'create user' do
    subject { post '/api/v1/auth/', headers: headers, params: params }

    let(:user) { build(:user) }
    let(:params) { user.attributes }
    let(:headers) { {} }

    it 'creates user' do
      expect { subject }.to change { User.count }.by(1)
      expect(user.phone).to eq(User.last.phone)
    end
  end
end
