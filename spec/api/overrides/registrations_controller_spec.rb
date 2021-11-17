require 'rails_helper'

RSpec.describe Overrides::RegistrationsController do
  describe 'new user registration' do
    context 'sending otp code' do
      if ENV['TWILLIO_TEST']
        ENV['DO_NOT_SEND_SMS'] = nil

        module Delayed
          def Job.enqueue(job)
            job.perform
          end
        end

        subject { post '/api/v1/auth', headers: headers, params: params }

        let(:user) { build(:user, phone: ENV['TWILLIO_TEST_PHONE']) }
        let(:params) { user.attributes }
        let(:headers) { {} }

        it 'creates user' do
          expect { subject }.to change { User.count }.by(1)
        end
      end end
  end

  context 'change user credentials' do
    subject { put '/api/v1/auth', headers: headers, params: params }

    def to_params(attributes)
      params = attributes.symbolize_keys.slice(*described_class::CREDENTIALS_PARAMS)
      params[:notification] = params[:notification]['late'].merge('type' => 'late', 'interval' => 100)
      params
    end

    let(:user) { create(:user) }
    let(:headers) { auth_headers }
    let(:params) { to_params(build(:user).attributes) }

    before { sign_in(user) }

    it 'change user credentials' do
      expect(to_params(user.attributes)).not_to eq(params)

      subject

      expect(to_params(user.reload.attributes)).to eq(params)
    end
  end
end
