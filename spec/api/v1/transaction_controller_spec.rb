require 'rails_helper'

RSpec.describe Api::V1::TransactionsController do
  context 'expenses' do
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
