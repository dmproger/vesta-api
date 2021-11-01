require 'rails_helper'

RSpec.describe Api::V1::UsersController do
  let!(:user) { create(:user) }

  let(:count) { rand(2..3) }
  let(:messages) { create_list(:message, count, user: user) }
  let(:message) { create(:message, user: user) }
  let(:params) { build(:message, user: user).attributes_before_type_cast.slice(*%w[topic text kind]) }

  let(:headers) { auth_headers }
  let(:json_body) { JSON.parse(body) }
  let(:data) { json_body['data'] }

  before { sign_in(user) }

  describe 'when POST /api/v1/messages' do
    subject(:send_request) { post '/api/v1/messages', params: params, headers: headers }

    it 'creates message' do
      expect { subject }.to change { Message.count }.by(1)
      expect(Message.last.attributes.to_s).to include(*params.slice(%w[topic text]).values)
    end
  end

  describe 'when GET /api/v1/messages' do
    subject(:send_request) { get '/api/v1/messages', params: params, headers: headers }

    let(:topics) { messages.map(&:topic) }
    let(:texts) { messages.map(&:text) }

    before { messages }

    it 'returns messages' do
      subject
      expect(data.count).to eq(count)
      expect(data.to_s).to include(*[topics + texts].flatten)
    end

    context 'when not existing messages kind' do
      before { params.merge!(kind: 100) }

      it 'returns empty array' do
        subject
        expect(data).to eq([])
      end
    end
  end

  describe 'when GET /api/v1/messages/:id' do
    subject(:send_request) { get "/api/v1/messages/#{ message.id }", params: params, headers: headers }

  end

  describe 'when PATCH /api/v1/messages/:id' do
    subject(:send_request) { get "/api/v1/messages/#{ message.id }", params: params, headers: headers }

  end

  describe 'when DELETE /api/v1/messages/:id' do
    subject(:send_request) { get "/api/v1/messages/#{ message.id }", params: params, headers: headers }

  end
end 
