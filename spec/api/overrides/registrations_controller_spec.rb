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
      end
    end
  end

  context 'change user credentials' do
    subject { put '/api/v1/auth', headers: headers, params: params }

    def to_credentials(attributes)
      attributes.symbolize_keys.slice(*described_class::CREDENTIALS_PARAMS)
    end

    let(:user) { create(:user) }
    let(:credentials) { to_credentials(build(:user).attributes) }

    let(:headers) { auth_headers }
    let(:params) { credentials }

    before { sign_in(user) }

    it 'change user credentials' do
      expect(to_credentials(user.attributes)).not_to eq(credentials)

      subject

      expect(to_credentials(user.reload.attributes)).to eq(credentials)
    end
  end
end
