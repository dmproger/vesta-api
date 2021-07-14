require 'rails_helper'

RSpec.describe Api::V1::ExpensesController do
  describe 'when GET /api/v1/expenses' do
    subject(:send_request) { get '/api/v1/expenses', params: params, headers: headers }

    let!(:user) { create(:user) }
    let!(:headers) { auth_headers }

    context 'for defaults only' do
      it 'returns default list' do
        subject
        expect(body).to include(*Expense::DEFAULTS)
      end
    end

    context 'when user created expenses' do
      let!(:expenses) { create_list(:expense, rand(2..3), user: user) }
      let!(:other_user) { create(:user) }
      let!(:other_expenses) { create_list(:expense, rand(2..3), user: other_user) }

      it 'returns all user expenses' do
        subject

        expect(body).to include(*expenses.map(&:name))
        expect(body).not_to include(*other_expenses.map(&:name))
      end
    end
  end

  describe 'when POST /api/v1/expenses' do
    subject(:send_request) { post '/api/v1/expenses', params: params, headers: headers }

    let!(:user) { create(:user) }
    let!(:other_user) { create(:user) }
    let!(:other_expenses) { create_list(:expense, rand(2..3), user: other_user) }

    let!(:headers) { auth_headers }
    let!(:params) { { name: 'FOO' } }

    before { sign_in(user) }

    it 'returns all user expenses' do
      subject

      get '/api/v1/expenses', headers: headers
      expect(body).to include(params[:name])
      expect(body).not_to include(*other_expenses.map(&:name))
    end
  end

  describe 'when PUT /api/v1/expenses' do
    subject(:send_request) { put "/api/v1/expenses/#{ expense.id }", params: params, headers: headers }

    let!(:user) { create(:user) }
    let!(:expense) { create(:expense, user: user) }
    let!(:other_user) { create(:user) }
    let!(:other_expense) { create(:expense, user: other_user) }

    let!(:headers) { auth_headers }
    let!(:params) { { name: 'BAR' } }

    before { sign_in(user) }

    it 'returns all user expenses' do
      get '/api/v1/expenses', headers: headers
      expect(body).to include(expense.name)
      expect(body).not_to include(params[:name])

      subject

      get '/api/v1/expenses', headers: headers
      expect(body).to include(params[:name])
      expect(body).not_to include(other_expense.name)
    end
  end

  describe 'when DELETE /api/v1/expenses' do
    subject(:send_request) { delete "/api/v1/expenses/#{ expense.id }", params: params, headers: headers }

    let!(:user) { create(:user) }
    let!(:expense) { create(:expense, user: user) }

    let!(:headers) { auth_headers }

    before { sign_in(user) }

    it 'returns all user expenses' do
      get '/api/v1/expenses', headers: headers
      expect(body).to include(expense.name)

      subject

      get '/api/v1/expenses', headers: headers
      expect(body).not_to include(expense.name)
    end
  end
end
