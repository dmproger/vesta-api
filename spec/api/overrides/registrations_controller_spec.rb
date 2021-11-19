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
    subject { patch '/api/v1/auth', headers: headers, params: params }

    def to_params(attributes)
      attributes.slice(*described_class::PARAMS_TO_UPDATE)
    end

    let(:user) { create(:user) }
    let(:headers) { auth_headers }
    let(:params) { to_params(build(:user).attributes.merge(patched_params)) }
    let(:user_params) { to_params(user.attributes.merge(patched_params)) }
    let(:updated_user_params) { to_params(user.reload.attributes.merge(patched_params)) }

    before { sign_in(user) }

    context 'late notification' do
      let(:patched_params) do
        {
          'late_notification' => { 'enable' => true, 'interval' => 100 },
          'rent_notification' => nil
        }
      end

      it 'updates user params' do
        expect(user_params).not_to eq(params)
        subject
        expect(updated_user_params).to eq(params)
      end
    end

    context 'rent notification' do
      let(:patched_params) do
        {
          'rent_notification' => { 'enable' => true },
          'late_notification' => nil
        }
      end

      it 'updates user params' do
        expect(user_params).not_to eq(params)
        subject
        expect(updated_user_params).to eq(params)
      end
    end
  end
end
