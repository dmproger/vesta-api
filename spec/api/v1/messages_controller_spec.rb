require 'rails_helper'

RSpec.describe Api::V1::UsersController do
  let!(:user) { create(:user) }

  let(:count) { rand(2..3) }
  let(:messages) { create_list(:message, count, user: user) }
  let(:message) { create(:message, user: user) }

  let(:other_user) { create(:user) }
  let(:other_message) { create(:message, user: other_user) }
  let(:other_messages) { create_list(:message, rand(2..3), user: other_user) }

  let(:headers) { auth_headers }
  let(:json_body) { JSON.parse(body) }
  let(:data) { json_body['data'] }

  let(:message_params) { build(:message, user: user).slice(*%w[kind department topic text viewed]) }
  let(:params) { message_params }

  before { sign_in(user) }

  describe 'when GET /api/v1/messages/departments' do
    subject(:send_request) { get '/api/v1/messages/departments', params: params, headers: headers }

    it 'returns departments' do
      subject
      expect(data).to eq(Message::DEPARTMENTS.stringify_keys)
    end
  end

  describe 'when GET /api/v1/messages/kinds' do
    subject(:send_request) { get '/api/v1/messages/kinds', params: params, headers: headers }

    it 'returns kinds' do
      subject
      expect(data).to eq(Message::KINDS.stringify_keys)
    end
  end

  describe 'when POST /api/v1/messages' do
    subject(:send_request) { post '/api/v1/messages', params: params, headers: headers }

    it 'creates message' do
      expect { subject }.to change { Message.count }.by(1)
      expect(Message.last.attributes.to_s).to include(*params.values.map(&:to_s))
    end
  end

  describe 'when GET /api/v1/messages' do
    subject(:send_request) { get '/api/v1/messages', params: params, headers: headers }

    let(:topics) { messages.map(&:topic) }
    let(:texts) { messages.map(&:text) }

    let(:params) { {} }

    before { messages }

    it 'returns messages' do
      subject
      expect(data.count).to eq(count)
      expect(data.to_s).to include(*[topics + texts].flatten)
    end

    context 'filtering messages by params' do
      let(:filter) { { viewed: true, kind: :income } }
      let(:filter_params) { filter.slice(filter.keys.sample, filter.keys.sample) }
      let(:filtered_messages) { create_list(:message, rand(2..3), user: user, **filter_params) }

      let(:params) { filter_params }

      before { messages && filtered_messages }

      it 'returns filtered messages' do
        subject
        expect(data.to_s).to include(*filtered_messages.map(&:id))
        expect(data.to_s).not_to include(*messages.map(&:id))
      end

      it 'returns empty list when target messages not exists' do
        filter_params.merge!(topic: 'foo')
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
