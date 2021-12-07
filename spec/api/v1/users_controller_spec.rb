require 'rails_helper'

RSpec.describe Api::V1::UsersController do
  let!(:user) { create(:user) }

  let(:params) { {} }
  let(:headers) { auth_headers }
  let(:json_body) { JSON.parse(body) }
  let(:data) { json_body['data'] }

  before { sign_in(user) }

  describe 'when PATCH /api/v1/users/:id' do
    subject { patch "/api/v1/users/#{ user.id }", headers: headers, params: params }

    def to_params(attributes)
      attributes.slice(*described_class::PARAMS_TO_UPDATE.map(&:to_s))
    end

    let(:params) { patched_params.stringify_keys }
    let(:user_params) { user.attributes.slice(*params.keys) }
    let(:updated_user_params) { user.reload.attributes.slice(*params.keys) }

    context 'personal data' do
      let(:patched_params) do
        {
          'first_name': 'Mr. Jhon',
          'email': 'mr_jhon@email.com'
        }
      end

      it 'updates personal data' do
        expect(user_params).not_to eq(params)
        subject
        expect(updated_user_params).to eq(params)
      end
    end

    context 'late notification only' do
      let(:patched_params) do
        {
          'late_notification' => { 'enable' => true, 'interval' => 100, 'time' => '11:11' },
        }
      end

      it 'updates notification config' do
        expect(user_params).not_to eq(params)
        subject
        expect(updated_user_params).to eq(params)
      end
    end

    context 'rent notification only' do
      let(:patched_params) do
        {
          'rent_notification' => { 'enable' => true },
        }
      end

      it 'updates notification config' do
        expect(user_params).not_to eq(params)
        subject
        expect(updated_user_params).to eq(params)
      end
    end

    context 'late and rent notification' do
      let(:patched_params) do
        {
          'late_notification' => { 'enable' => true, 'interval' => 100, 'time' => '11:11' },
          'rent_notification' => { 'enable' => true },
        }
      end

      it 'updates notification config' do
        expect(user_params).not_to eq(params)
        subject
        expect(updated_user_params).to eq(params)
      end
    end

    context 'incorrect interval notification param' do
      let(:patched_params) do
        {
          'late_notification' => { 'enable' => true, 'interval' => 1000, 'time' => '11:11' },
        }
      end

      it 'do not updates notification config' do
        subject
        expect(user.attributes).to eq(user.reload.attributes)
        expect(json_body["success"]).to be_falsey
      end
    end

    context 'incorrect time notification param' do
      let(:patched_params) do
        {
          'late_notification' => { 'enable' => true, 'interval' => 100, 'time' => 'foo' },
        }
      end

      it 'do not updates notification config' do
        subject
        expect(user.attributes).to eq(user.reload.attributes)
        expect(json_body["success"]).to be_falsey
      end
    end
  end

  describe 'when GET /api/v1/users/:id/notifications' do
    subject(:send_request) { get "/api/v1/users/#{ user.id }/notifications", params: params, headers: headers }

    let(:rent_notifications) { create_list(:notification, rand(2..3), user: user, subject: :rental_payment) }
    let(:late_notifications) { create_list(:notification, rand(2..3), user: user, subject: :late_payment) }

    it 'returns all notifications' do
      rent_notifications && late_notifications

      subject
      expect(data.to_s).to include(*rent_notifications.pluck(:id))
      expect(data.to_s).to include(*late_notifications.pluck(:id))
    end

    it 'returns rent notifications' do
      rent_notifications
      params.merge!(type: 'rent')

      subject
      expect(data.to_s).to include(*rent_notifications.pluck(:id))
      expect(data.to_s).not_to include(*late_notifications.pluck(:id))
    end

    it 'returns late notifications' do
      late_notifications
      params.merge!(type: 'late')

      subject
      expect(data.to_s).to include(*late_notifications.pluck(:id))
      expect(data.to_s).not_to include(*rent_notifications.pluck(:id))
    end
  end
end
