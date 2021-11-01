require 'rails_helper'

RSpec.describe Api::V1::UsersController do
  let!(:user) { create(:user) }

  let(:topic) { Faker::Book.title }
  let(:text) { Faker::Movie.title }
  let(:params) { { topic: topic, text: text, kind: 1 } }

  let(:headers) { auth_headers }
  let(:json_body) { JSON.parse(body) }
  let(:data) { json_body['data'] }

  before { sign_in(user) }

  describe 'when POST /api/v1/messages' do
    subject(:send_request) { post '/api/v1/messages', params: params, headers: headers }

    it 'creates message' do
      expect { subject }.to change { Message.count }.by(1)
      expect(Message.last.attributes.to_s).to include(*params.slice(:topic, :text).values)
    end
  end

  describe 'when GET /api/v1/messages' do
    subject(:send_request) { get '/api/v1/messages', params: params, headers: headers }

    let(:count) { rand(2..3) }

    before do
      Message.delete_all
      count.times { post '/api/v1/messages', params: params, headers: headers }
    end

    it 'returns messages' do
      subject
      expect(data.count).to eq(count)
      expect(data.to_s).to include(*params.slice(:topic, :text).values)
    end

    context 'when not existing messages kind' do
      let!(:not_existing_kind_params) { params.merge!(kind: 100) }

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
