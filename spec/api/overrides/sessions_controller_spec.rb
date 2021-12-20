require 'rails_helper'

# module Delayed
#   def Job.enqueue(job)
#     job.perform
#   end
# end

ENV.delete('DO_NOT_SEND_SMS') if ENV['TWILLIO_TEST']

RSpec.describe Overrides::SessionsController do
  describe 'create user session' do
    subject { post '/api/v1/auth/sign_in', headers: headers, params: params }

    context 'sending otp code' do
      let(:user) { create(:user, phone: ENV['TWILLIO_TEST_PHONE']) }
      let(:params) { user.attributes }
      let(:headers) { {} }

      before { subject }

      it 'check your TWILLIO_TEST_PHONE for sms' do
        true
      end
    end
  end
end
