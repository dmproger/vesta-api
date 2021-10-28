require 'rails_helper'

RSpec.describe Api::V1::UsersController do
  VERSION = described_class::NOTIFICATION_VERSION

  let!(:user) { create(:user) }
  let(:config) { { type: 'late', interval: '3', time: '15:30' } }
  let(:headers) { auth_headers }
  let(:json_body) { JSON.parse(body) }
  let(:data) { json_body['data'] }

  before { sign_in(user) }

  describe 'when GET /api/v1/users/:id/notification_config' do
    subject(:send_request) { get "/api/v1/users/#{ user.id }/notification_config", params: params, headers: headers }

    it 'returns notification config' do
      user.update! notification: { VERSION => config.stringify_keys }

      subject
      expect(data).to eq(config.stringify_keys)
    end
  end

  describe 'when POST /api/v1/users/:id/notification_config' do
    subject(:send_request) { post "/api/v1/users/#{ user.id }/notification_config", params: params, headers: headers }

    let(:params) { config }

    it 'creates notification config' do
      user.update! notification: nil

      subject
      expect(user.reload.notification).to eq(VERSION => config.stringify_keys)
    end

    it 'returns error if any config missed' do
      params.delete(params.keys.sample)

      subject
      expect(json_body["success"]).to eq(false)
    end
  end

  describe 'when PATCH /api/v1/users/:id/notification_config' do
    subject(:send_request) { patch "/api/v1/users/#{ user.id }/notification_config", params: params, headers: headers }

    let(:interval) { '10' }
    let(:params) { config.merge(interval: interval) }

    it 'updates notification config' do
      user.update! notification: { VERSION => config.stringify_keys }

      subject
      expect(user.reload.notification[VERSION]["interval"]).to eq(interval)
    end
  end

  describe 'when DELETE /api/v1/users/:id/notification_config' do
    subject(:send_request) { delete "/api/v1/users/#{ user.id }/notification_config", params: params, headers: headers }

    it 'disable notification (remove config)' do
      user.update! notification: { VERSION => config.stringify_keys }

      subject
      expect(user.reload.notification).to eq(nil)
    end
  end
end
