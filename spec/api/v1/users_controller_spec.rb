require 'rails_helper'

RSpec.describe Api::V1::UsersController do
  VERSION = described_class::NOTIFICATION_VERSION

  let!(:user) { create(:user) }
  let(:config) { { type: 'late', interval: '3', time: '15:30', enable: '1' } }
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

    let(:interval) { '10' }
    let(:params) { config.merge(interval: interval) }

    it 'updates notification config' do
      user.update! notification: { VERSION => config.stringify_keys }

      subject
      expect(user.reload.notification[VERSION]).to eq(params.stringify_keys)
    end
  end

  describe 'when DELETE /api/v1/users/:id/notification_config' do
    subject(:send_request) { delete "/api/v1/users/#{ user.id }/notification_config", params: params, headers: headers }

    it 'disable notification (remove config)' do
      user.update! notification: { VERSION => config.stringify_keys }

      subject
      expect(user.reload.notification).to be_nil
    end
  end
end
