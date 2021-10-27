require 'rails_helper'

RSpec.describe Api::V1::UsersController do
  VERSION = described_class::NOTIFICATION_VERSION

  let!(:user) { create(:user) }
  let!(:config) { { VERSION => { type: 'late', interval: '3', time: '15:30' } } }

  before { sign_in(user) }

  describe 'when GET /api/v1/users/notification_config' do
    subject(:send_request) { get '/api/v1/users/notification_config', params: params, headers: headers }

    before do
      sign_in(user)
      user.update! notification: config
    end

    it 'returns notification' do
      byebug
    end
  end

  describe 'when POST /api/v1/users/notification_config' do
    subject(:send_request) { post '/api/v1/users/notification_config', params: params, headers: headers }

  end

  describe 'when PATCH /api/v1/users/notification_config' do
    subject(:send_request) { patch '/api/v1/users/notification_config', params: params, headers: headers }

  end
end
