require 'rails_helper'

RSpec.describe Notification, type: :model do
  describe '.rental_payment!' do
    subject { described_class.rental_payment!(user, transactions) }

    let(:user) { create(:user) }
    let(:account) { create(:account) }
    let(:tenant) { create(:tenant) }
    let(:properties) { create_list(:property, rand(3..4), user: user) }
    let(:property_tenants) do
      results = []
      properties.each do |property|
        results << create(:property_tenant, property: property, tenant: tenant)
      end
      results
    end
    let(:saved_transactions) { create_list(:saved_transaction, properties.count, user: user, account: account, transaction_date: Date.current - 1.day) }
    let(:associated_transactions) do
      saved_transactions.each_with_index do |saved_transaction, index|
        create(:associated_transaction, saved_transaction: saved_transaction, property_tenant: property_tenants[index])
      end
    end
    let(:addresses) do
      SavedTransaction.
        where(id: saved_transactions.pluck(:id)).
        joins(associated_transaction: :property).
        pluck(:address)
    end

    let(:transactions) { associated_transactions && saved_transactions }

    it 'creates notifications with correct data' do
      expect { subject }.to change { described_class.count }.by(transactions.count)

      expect(Notification.pluck(:title).uniq).to eq(['Rental payment recived'])
      expect(Notification.pluck(:text).join).to include(*(transactions.pluck(:description, :amount).flatten.map(&:to_s) + addresses))
    end
  end
end
