require 'rails_helper'

RSpec.describe Api::V1::UsersController do
  let!(:user) { create(:user) }

  let(:type) { 'late' }
  let(:config) { { 'interval' => 3, 'time' => '15:30', 'enable' => true } }
  let(:notification) { { type => config } }
  let(:notification_json) { { type.to_s => config.stringify_keys } }
  let(:params) { { type: type }.merge(config) }

  let(:headers) { auth_headers }
  let(:json_body) { JSON.parse(body) }
  let(:data) { json_body['data'] }

  before { sign_in(user) }

  describe 'when GET /api/v1/users/:id/notification_config' do
    subject(:send_request) { get "/api/v1/users/#{ user.id }/notification_config", params: params, headers: headers }

    it 'returns notification config' do
      user.update! notification: notification

      subject
      expect(data).to eq(notification_json)
    end

    it 'returns default notification config if config not exists' do
      user.update! notification: nil

      subject
      expect(data).to eq(described_class::DEFAULT_NOTIFICATION)
    end
  end

  describe 'when POST /api/v1/users/:id/notification_config' do
    subject(:send_request) { post "/api/v1/users/#{ user.id }/notification_config", params: params, headers: headers }

    it 'creates notification config' do
      user.update! notification: nil

      subject
      expect(user.reload.notification).to eq(notification_json)
    end

    it 'returns error if any config missed' do
      params.delete(params.keys.sample)

      subject
      expect(json_body["success"]).to be_falsey
    end

    it 'returns error if time wrong format' do
      user.update! notification: nil
      params.merge!(time: '23:0')

      subject
      expect(json_body["success"]).to be_falsey
      expect(user.reload.notification).to be_nil
    end
    it 'returns error if interval wrong format' do
      user.update! notification: nil
      params.merge!(interval: '230')

      subject
      expect(json_body["success"]).to be_falsey
      expect(user.reload.notification).to be_nil
    end

    it 'returns error if type wrong format' do
      user.update! notification: nil
      params.merge!(type: 'foo')

      subject
      expect(json_body["success"]).to eq(false)
      expect(user.reload.notification).to be_nil
    end

    it 'returns error if enable wrong format' do
      user.update! notification: nil
      params.merge!(enable: '3')

      subject
      expect(json_body["success"]).to eq(false)
      expect(user.reload.notification).to be_nil
    end
  end

  describe 'when PATCH /api/v1/users/:id/notification_config' do
    subject(:send_request) { patch "/api/v1/users/#{ user.id }/notification_config", params: params, headers: headers }

    let(:patched_interval) { { 'interval' => 10 } }
    let(:patched_time) { { 'time' => '10:00' } }
    let(:patched_enable) { { 'enable' => true } }

    before { user.update notification: notification }

    it 'updates notification interval' do
      params.merge!(patched_interval)

      subject
      expect(user.reload.notification[type]['interval']).to eq(patched_interval['interval'])
    end

    it 'updates notification time' do
      params.merge!(patched_time)

      subject
      expect(user.reload.notification[type]['time']).to eq(patched_time['time'])
    end
    it 'updates notification enable' do
      params.merge!(patched_enable)

      subject
      expect(user.reload.notification[type]['enable']).to eq(patched_enable['enable'])
    end
  end

  describe 'when DELETE /api/v1/users/:id/notification_config' do
    subject(:send_request) { delete "/api/v1/users/#{ user.id }/notification_config", params: params, headers: headers }

    it 'disable notification (remove config)' do
      user.update! notification: notification

      subject
      expect(user.reload.notification).to be_nil
    end
  end
end
