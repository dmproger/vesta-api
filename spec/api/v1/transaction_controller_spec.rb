require 'rails_helper'

RSpec.describe Api::V1::TransactionsController do
  describe 'when GET /api/v1/transactions/all' do
    subject(:send_request) { get '/api/v1/transactions/all', params: params, headers: headers }

    TRANSACTION_TYPES = %w[INCOME EXPENSES TRANSFERS]

    let!(:user) { create(:user) }
    let!(:account1) { create(:account) }
    let!(:account2) { create(:account) }
    let!(:date_valid_transactions) do
      result = []
      for type in TRANSACTION_TYPES
        result << create_list(:saved_transaction, rand(2..3), user: user, account: account1, category_type: type)
        result << create_list(:saved_transaction, rand(2..3), user: user, account: account2, category_type: type)
      end
      SavedTransaction.where(id: result.flatten.map(&:id))
    end
    let!(:date_invalid_transactions) do
      result = []
      for type in TRANSACTION_TYPES
        result << create_list(:saved_transaction, rand(2..3), user: user, account: account1, category_type: type, transaction_date: Date.current - 20.day)
        result << create_list(:saved_transaction, rand(2..3), user: user, account: account2, category_type: type, transaction_date: Date.current + 20.day)
      end
      SavedTransaction.where(id: result.flatten.map(&:id))
    end
    let!(:transactions) do
      SavedTransaction.where(id: [date_valid_transactions.ids + date_invalid_transactions.ids])
    end

    let(:headers) { auth_headers }
    let(:params) { { start_date: Date.current - 1.year, end_date: Date.current + 1.year } }

    before { sign_in(user) }

    context 'for no date transactions' do
      it 'returns all transactions' do
        subject
        expect(body).to include(*transactions.ids)
      end

      for $type in TRANSACTION_TYPES
        it "returns #{ $type } type transactions" do
          params.merge(type: $type)
          subject
          expect(body).to include(*transactions.where(category_type: $type).ids)
        end
      end
    end

    context 'for date period transactions' do
      it 'filter by period' do
        min_date = transactions.pluck(:transaction_date).min
        max_date = transactions.pluck(:transaction_date).max

        params.merge!(start_date: min_date - 1.day, end_date: max_date + 1.day)
        subject
        expect(body).to include(*transactions.ids)

        params.merge!(start_date: min_date - 20.days, end_date: max_date - 10.days)
        subject
        # TODO
        expect(body).not_to include(*transactions.ids)
      end
    end
  end

  describe 'transaction assigns' do
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
