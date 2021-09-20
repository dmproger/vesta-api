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

    let(:tink_transactions) { build_list(:tink_transaction, rand(3..4)) }
    let!(:saved_transactions_count) { user.saved_transactions.count }

    before { subject }

    it 'add new transactions' do
      expect(user.saved_transactions.reload.count).to eq(saved_transactions_count + user.accounts.count * tink_transactions.count)
    end
  end

  describe '.get_rental_payment' do
    subject { described_class.get_rental_payment([user]) }

    let(:tenants) { create_list(:tenant, rand(3..4)) }
    let(:properties) { create_list(:property, rand(3..4), user: user) }
    let(:property_tenants) do
      for property, index in properties.each_with_index
        create(:property_tenant, property: property, tenant: tenants[index])
      end
    end
    let(:tink_transactions) do
      tenants.each_with_object([]) do |tenant, tink_transactions|
        tink_transactions << build(:tink_transaction, name: tenant.name)
      end.flatten
    end

    before { subject }

    it 'associates with properties' do
      for property, index in properties.each_with_index
        expect(property.saved_transactions).not_to be_empty
      end
    end

    it 'creates notifications' do
      # TODO
    end
  end
end
