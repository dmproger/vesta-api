require 'rails_helper'

RSpec.describe Api::V1::UsersController do
  let!(:user) { create(:user) }

  let(:topic) { Faker::Book.title }
  let(:text) { Faker::Movie.title }
  let(:params) { { topic: topic, text: text, kind: 1 } }

  let(:headers) { auth_headers }

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
