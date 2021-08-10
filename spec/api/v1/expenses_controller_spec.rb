require 'rails_helper'

RSpec.describe Api::V1::ExpensesController do
  let!(:user) { create(:user) }
  let!(:other_user) { create(:user) }

  let(:expense) { create(:expense, user: user) }
  let(:expenses) { create_list(:expense, rand(2..3), user: user) }
  let(:other_expense) { create(:expense, user: user) }
  let(:other_expenses) { create_list(:expense, rand(2..3), user: other_user) }

  let(:headers) { auth_headers }
  let(:params) { {} }

  before { sign_in(user) }

  describe 'when GET /api/v1/expenses' do
    subject(:send_request) { get '/api/v1/expenses', params: params, headers: headers }


    context 'when user has no created expenses' do
      it 'returns default expenses' do
        subject

        expect(body).to include(*Expense::DEFAULTS)

        # check, that default expenses created only once
        default_expenses = JSON.parse(body)['data']
        get '/api/v1/expenses', params: params, headers: headers
        expect(JSON.parse(body)['data'].map { |r| r['id'] }.sort).to eq(default_expenses.map { |r| r['id'] }.sort)
      end
    end

    context 'when user has created expenses' do
      before { expenses }

      it 'returns users and default expenses' do
        subject

        expect(body).to include(*(expenses.map(&:name) + Expense::DEFAULTS))
        expect(body).not_to include(*other_expenses.map(&:name))
      end
    end
  end

  describe 'when GET /api/v1/expenses/:id' do
    subject(:send_request) { get "/api/v1/expenses/#{ expense.id }", params: params, headers: headers }

    it 'returns specific expense' do
      subject

      expect(body).to include(expense.id)
      expect(body).not_to include(other_expense.id)
    end
  end

  describe 'when POST /api/v1/expenses' do
    subject(:send_request) { post '/api/v1/expenses', params: params, headers: headers }

    let(:name) { 'FOO' }
    let(:params) { { name: name } }

    it 'creates expense' do
      expect { subject }.to change { Expense.count }.by(1)

      expect(body).to include(name)
      expect(body).to include(Expense.new.report_state)
    end
  end

  describe 'when PUT /api/v1/expenses/:id' do
    subject(:send_request) { put "/api/v1/expenses/#{ expense.id }", params: params, headers: headers }

    let(:name) { 'BAR' }
    let(:report_state) { (Expense.report_states.keys - [Expense.new.report_state]).sample }
    let(:params) { { name: name, report_state: report_state } }

    it 'update specific expense' do
      expect(expense.name).not_to eq(name)
      expect(expense.report_state).not_to eq(report_state)

      subject

      expense.reload
      expect(expense.name).to eq(name)
      expect(expense.report_state).to eq(report_state)
    end
  end

  describe 'when DELETE /api/v1/expenses' do
    subject(:send_request) { delete "/api/v1/expenses/#{ expense.id }", params: params, headers: headers }

    it 'delete specific expense' do
      expect { Expense.find(expense.id) }.not_to raise_error

      subject

      expect { Expense.find(expense.id) }.to raise_error(ActiveRecord::RecordNotFound)
    end
  end
end
