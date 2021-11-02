require 'rails_helper'

RSpec.describe Api::V1::UsersController do
  let!(:user) { create(:user) }

  let(:count) { rand(2..3) }
  let(:messages) { create_list(:message, count, user: user) }
  let(:message) { create(:message, user: user) }
  let(:params) { build(:message, user: user).attributes_before_type_cast.slice(*%w[topic text kind]) }

  let(:other_user) { create(:user) }
  let(:other_message) { create(:message, user: other_user) }
  let(:other_messages) { create_list(:message, rand(2..3), user: other_user) }

  let(:headers) { auth_headers }
  let(:json_body) { JSON.parse(body) }
  let(:data) { json_body['data'] }

  before { sign_in(user) }

  describe 'when GET /api/v1/messages/kinds' do
    subject(:send_request) { get '/api/v1/messages/kinds', params: params, headers: headers }

    it 'returns kinds' do
      subject
      expect(data.to_s).to include(*[Message::KINDS.values + Message.kinds.values.map(&:to_s)].flatten)
    end
  end

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

    context 'of other user' do
      let(:messages) { other_messages }

      it 'not includes other user messages' do
        subject 
        expect(data.to_s).not_to include(*[topics + texts].flatten)
      end
    end
  end

  describe 'when GET /api/v1/messages/:id' do
    subject(:send_request) { get "/api/v1/messages/#{ message.id }", params: params, headers: headers }

    it 'returns specific message' do
      subject
      expect(data.class).to eq(Hash)
      expect(data.slice(%w[topic text]).values.sort).to eq(message.attributes.slice(%w[topic text]).sort)
    end

    context 'of other user' do
      let(:message) { other_message }

      it 'do not returns other user message' do
        expect { subject }.to raise_error(ActiveRecord::RecordNotFound)
      end
    end
  end

  describe 'when PATCH /api/v1/messages/:id' do
    subject(:send_request) { patch "/api/v1/messages/#{ message.id }", params: params, headers: headers }

    before { params.merge!(topic: 'foo', viewed: !message.viewed) }

    it 'update message' do
      subject
      message.reload
      expect(message.topic).to eq(params[:topic])
      expect(message.viewed).to eq(params[:viewed])
    end

    context 'of other user' do
      let(:message) { other_message }

      it 'do not returns other user message' do
        expect { subject }.to raise_error(ActiveRecord::RecordNotFound)
      end
    end
  end

  describe 'when DELETE /api/v1/messages/:id' do
    subject(:send_request) { delete "/api/v1/messages/#{ message.id }", params: params, headers: headers }

    it 'delete message' do
      subject
      expect { message.reload }.to raise_error(ActiveRecord::RecordNotFound)
    end

    context 'of other user' do
      let(:message) { other_message }

      it 'do not destroy other user message' do
        expect { subject }.to raise_error(ActiveRecord::RecordNotFound)
      end
    end
  end
end 
