require 'rails_helper'

MODELS = [
  Account,
  SavedTransaction,
  AssociatedTransaction,
  Notification,
  Property,
  Tenant,
  PropertyTenant
]
require_relative '../support/manual/test_user_data'
require_relative '../support/mock'

RSpec.describe TinkService do
  describe '.get_rental_payment' do
    subject { described_class.get_rental_payment([user]) }

    let(:user) { USER }
    let(:tink_transactions) { build_list(:tink_transaction, rand(3..4)) }
    let!(:saved_transactions_count) { user.saved_transactions.count }

    before do
      mock(described_class.singleton_class, :get_tink_transactions, tink_transactions)
      subject
    end

    it 'grabs tink transactions' do
      expect(user.saved_transactions.reload.count).to eq(saved_transactions_count + user.accounts.count * tink_transactions.count)
    end

    it 'associates with properties' do
      # TODO
    end

    it 'creates notifications' do
      # TODO
    end
  end
end
