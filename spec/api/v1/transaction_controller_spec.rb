require 'rails_helper'

RSpec.describe Api::V1::TransactionsController do
  context 'expenses' do
    describe 'when GET /api/v1/transactions/:id/assign_expenses' do
      subject(:send_request) { post "/api/v1/transactions/#{ transaction.id }/assign_expenses", params: params, headers: headers }

      let!(:user) { create(:user) }
      let!(:account) { create(:account) }
      let!(:transaction) { create(:saved_transaction, user: user, account: account) }
      let!(:headers) { auth_headers }

      before { sign_in(user) }

      it 'assign expenses category' do
        subject
        expect(body).to include('success')
      end
    end
  end
end
