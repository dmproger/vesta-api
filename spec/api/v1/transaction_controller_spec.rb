require 'rails_helper'

RSpec.describe Api::V1::TransactionsController do
  describe 'when GET /api/v1/transactions/all' do
    subject(:send_request) { get '/api/v1/transactions/all', params: params, headers: headers }

    let(:user) { create(:user) }
    let(:account) { create(:account) }
    let(:types) { %w[INCOME EXPENSES TRANSFERS] }
    let(:transactions) do
      result = []
      for type in types
        (1..rand(2..3)).each do
          result << create(:saved_transaction, user: user, account: account, category_type: type)
          result << create(:saved_transaction, user: user, account: account, category_type: type, transaction_date: Date.current - 1.day)
          result << create(:saved_transaction, user: user, account: account, category_type: type, transaction_date: Date.current + 1.day)
        end
      end
      SavedTransaction.where(id: result.map(&:id))
    end

    let(:headers) { auth_headers }
    let(:params) { {} }

    it 'returns all transactions' do
      subject
      expect(body).to include(*transactions.ids)
    end

    it 'returns transactions by type' do
      for type in types
        params.merge(type: type)
        subject
        expect(body).to include(*transactions.where(category_type: type).ids)
      end
    end

    context 'when transaction date' do
      it 'filter by transaction date' do
        # TODO
      end
    end
  end

  context 'assigns' do
    describe 'when GET /api/v1/transactions/:id/assign_expenses' do
      subject(:send_request) { post "/api/v1/transactions/#{ transaction.id }/assign_expenses", params: params, headers: headers }

      let!(:user) { create(:user) }
      let!(:account) { create(:account) }
      let!(:transaction) { create(:saved_transaction, user: user, account: account) }
      let!(:property) { create(:property, user: user) }
      let!(:expense) { create(:expense, user: user) }

      let!(:headers) { auth_headers }
      let!(:params) { { property_id: property.id, expense_id: expense.id } }

      before { sign_in(user) }

      it 'assign expense to property and transaction' do
        subject
        expect(property.expense_transactions.first.id).to eq(transaction.id)
      end
    end
  end
end
