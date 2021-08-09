require 'rails_helper'

RSpec.describe Api::V1::TransactionsController do
  TRANSACTION_TYPES = %w[INCOME EXPENSES TRANSFERS]

  describe 'when GET /api/v1/transactions/types' do
    subject(:send_request) { get '/api/v1/transactions/types', params: params, headers: headers }

    let!(:user) { create(:user) }
    let!(:account1) { create(:account) }
    let!(:user2) { create(:user) }
    let!(:account2) { create(:account) }
    let!(:transactions) do
      for type in TRANSACTION_TYPES + %w[one two three]
        create_list(:saved_transaction, rand(2..3), user: user, account: account1, category_type: type)
      end
      for type in TRANSACTION_TYPES + %w[for five six]
        create_list(:saved_transaction, rand(2..3), user: user2, account: account2, category_type: type)
      end
    end
    let!(:types) { TRANSACTION_TYPES + %w[one two three for five six] }

    let!(:headers) { auth_headers }
    let(:params) { {} }

    before { sign_in(user) }

    it 'returns all transaction types' do
      subject
      expect(body).to include(*types)
    end
  end

  describe 'when GET /api/v1/transactions/all' do
    subject(:send_request) { get '/api/v1/transactions/all', params: params, headers: headers }

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
    let(:params) { {} }

    before { sign_in(user) }

    context 'for no date transactions' do
      context 'all transactions with expense categories included' do
        let!(:expense) { create(:expense, user: user) }
        let!(:property) { create(:property, user: user) }
        let!(:expense_transactions) { transactions.where(category_type: 'EXPENSES') }

        let(:data) { JSON.parse(body)['data'] }
        let(:expense_records) { data.keep_if { |r| r['category_type'] == 'EXPENSES' } }
        let(:other_records) { data.keep_if { |r| r['category_type'] != 'EXPENSES' } }

        before do
          expense_transactions.each do |transaction|
            property.assign_expense(expense, transaction)
            property.assign_expense(expense, transaction)
          end
        end

        it 'returns all transactions' do
          subject

          expect(body).to include(*transactions.ids)
          expect(body).to include(expense.name, expense.id)

          expense_names = expense_records.map { |r| r['expense_name'] }.uniq
          expect(expense_names.count).to eq(1)
          expect(expense_names.first).to eq(expense.name)

          expect(other_records).not_to include(expense.name)
        end
      end

      it 'returns income type transactions' do
        params.merge!(type: 'INCOME')

        subject
        expect(body).to include(*transactions.where(category_type: params[:type]).ids)
        expect(body).not_to include(*transactions.where(category_type: (TRANSACTION_TYPES - [params[:type]]).sample).ids)
      end

      it 'returns expenses type transactions' do
        params.merge!(type: 'EXPENSES')

        subject
        expect(body).to include(*transactions.where(category_type: params[:type]).ids)
        expect(body).not_to include(*transactions.where(category_type: (TRANSACTION_TYPES - [params[:type]]).sample).ids)
      end

      it 'returns transfers type transactions' do
        params.merge!(type: 'TRANSFERS')

        subject
        expect(body).to include(*transactions.where(category_type: params[:type]).ids)
        expect(body).not_to include(*transactions.where(category_type: (TRANSACTION_TYPES - [params[:type]]).sample).ids)
      end
    end

    context 'for date period transactions' do
      let(:min_date) { date_valid_transactions.pluck(:transaction_date).min }
      let(:max_date) { date_valid_transactions.pluck(:transaction_date).max }

      context 'included in filter period' do
        let(:params) { { start_date: min_date - 1.day, end_date: max_date + 1.day } }

        it 'returns date valid transactions' do
          subject
          expect(body).to include(*date_valid_transactions.ids)
        end
      end

      context 'not included in filter period' do
        let(:start_date) { date_invalid_transactions.pluck(:transaction_date).sample }
        let(:params) { { start_date: start_date, end_date: start_date + 1.day } }

        it 'not returns date valid transactions' do
          subject
          expect(body).not_to include(*date_valid_transactions.ids)
        end
      end

      context 'only start date in period' do
        let(:params) { { start_date: min_date - 1.day } }

        it 'returns date valid transactions' do
          subject
          expect(body).to include(*date_valid_transactions.ids)
        end
      end
      context 'only end date in period' do
        let(:params) { { end_date: max_date + 1.day } }

        it 'returns date valid transactions' do
          subject
          expect(body).to include(*date_valid_transactions.ids)
        end
      end
    end
  end

  describe 'transaction assigns' do
    describe 'when GET /api/v1/transactions/:id/assign_expenses' do
      subject(:send_request) { post "/api/v1/transactions/#{ transaction.id }/assign_expenses", params: params, headers: headers }

      let!(:user) { create(:user) }

      let(:account) { create(:account) }
      let(:expense_transaction) { create(:saved_transaction, user: user, account: account, category_type: 'EXPENSE') }
      let(:income_transaction) { create(:saved_transaction, user: user, account: account) }
      let(:property) { create(:property, user: user) }
      let(:expense) { create(:expense, user: user) }

      let(:headers) { auth_headers }
      let(:params) { { property_id: property.id, expense_id: expense.id } }

      before { sign_in(user) }

      context 'expense transaction' do
        let(:transaction) { expense_transaction }

        it 'assign expense to property and transaction' do
          subject
          expect(property.expense_transactions.first.id).to eq(transaction.id)
        end
      end

      context 'income transaction' do
        let(:transaction) { income_transaction }

        it 'raise error' do
          expect { subject }.to raise_error
        end
      end
    end
  end
end
