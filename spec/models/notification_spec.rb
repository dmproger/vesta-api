require 'rails_helper'

RSpec.describe Notification, type: :model do
  describe '.rental_payment!' do
    subject { described_class.rental_payment!(user, transactions) }

    let(:user) { create(:user) }
    let(:account) { create(:account) }
    let(:tenant) { create(:tenant) }
    let(:property) { create(:property, user: user) }
    let(:property_tenant) { create(:property_tenant, property: property, tenant: tenant) }
    let(:saved_transactions) { create_list(:saved_transaction, rand(3..4), user: user, account: account, transaction_date: Date.current - 1.day) }
    let(:associated_transactions) do
      saved_transactions.each do |saved_transaction|
        create(:associated_transaction, saved_transaction: saved_transaction, property_tenant: property_tenant)
      end
    end
    let(:addresses) do
      SavedTransaction.
        where(id: saved_transactions.pluck(:id)).
        joins(associated_transaction: :property).
        pluck(:address)
    end

    let(:transactions) { associated_transactions && saved_transactions }

    it 'creates notifications' do
      expect { subject }.to change { described_class.count }.by(saved_transactions.count)

      expect(Notification.pluck(:title).uniq).to eq(['Rental payment recived'])
      # TODO
      # expect(Notification.pluck(:text).join).to include(*(transactions.pluck(:description, :amount).map(&:to_s) + addresses))
    end
  end
end
