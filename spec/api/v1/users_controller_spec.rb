require 'rails_helper'

RSpec.describe Api::V1::UsersController do
  let!(:user) { create(:user) }
  let(:params) { {} }
  let(:headers) { auth_headers }
  let(:json_body) { JSON.parse(body) }
  let(:data) { json_body['data'] }

  before { sign_in(user) }

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
