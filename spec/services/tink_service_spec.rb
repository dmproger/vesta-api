return unless ENV['TINKTEST']

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
  let(:user) { USER }

  before { mock(described_class.singleton_class, :get_tink_transactions, tink_transactions) }

  describe '.grab_tink_transactions' do
    subject { described_class.grab_tink_transactions(user) }

    let(:accounts) { user.accounts }
    let(:tink_transactions) { build_list(:tink_transaction, rand(3..4)) }
    let(:tink_transaction_dates) { tink_transactions.map { |t| TinkService.to_time(t['transaction']['date']) } }
    let!(:current_transactions_ids) { user.saved_transactions.ids }
    let(:transactions) { user.saved_transactions.where.not(id: current_transactions_ids) }

    before { subject }

    it 'adds new transactions' do
      expect(transactions.count).to eq(tink_transactions.count * accounts.count)
    end

    it 'has correct transactions dates' do
      expect(transactions.pluck(:transaction_date).sort).to eq((tink_transaction_dates * accounts.count).sort)
    end
  end

  describe '.get_rental_payment' do
    subject { described_class.get_rental_payment([user]) }

    let(:tenants) { create_list(:tenant, rand(3..4), user: user) }
    let(:properties) { create_list(:property, rand(3..4), user: user) }
    let(:tink_transactions) do
      tenants.each_with_object([]) do |tenant, tink_transactions|
        tink_transactions << build(:tink_transaction, description: tenant.name)
      end.flatten
    end

    before { subject }

    it 'associates with properties' do
      # TODO
      for property, index in properties.each_with_index
        expect(property.saved_transactions).not_to be_empty
      end
    end

    it 'creates notifications' do
      # TODO
    end
  end
end
