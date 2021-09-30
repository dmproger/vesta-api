require 'rails_helper'
require_relative '../support/mock'

RSpec.describe TinkService do
  let(:user) { create(:user) }
  let!(:account) { create(:account, user: user) }

  before { mock(described_class.singleton_class, :get_tink_transactions, tink_transactions) }

  describe '.grab_tink_transactions' do
    subject { described_class.grab_tink_transactions(user) }

    let(:accounts) { user.accounts }
    let(:tink_transactions) { build_list(:tink_transaction, rand(3..4)) }
    let(:tink_transaction_dates) { tink_transactions.map { |t| TinkService.to_time(t['transaction']['date']) } }

    before { subject }

    it 'adds new transactions' do
      expect(user.saved_transactions.count).to eq(tink_transactions.count * accounts.count)
    end

    it 'has correct transactions dates' do
      expect(user.saved_transactions.pluck(:transaction_date).sort).to eq((tink_transaction_dates * accounts.count).sort)
    end
  end

  describe '.get_rental_payment' do
    subject { described_class.get_rental_payment([user], notification: notification) }

    let(:properties) { create_list(:property, rand(3..4), user: user) }
    let(:tenants) do
      properties.each_with_object([]) do |property, tenants|
        tenants << create(:tenant, property: property)
      end
    end
    let!(:tink_transactions) do
      tenants.each_with_object([]) do |tenant, tink_transactions|
        tink_transactions << build_list(:tink_transaction, rand(2..3), description: tenant.name)
      end.flatten
    end
    let!(:notification) { true }

    before { subject }

    it 'associates transactions with properties and tenants' do
      for property, index in properties.each_with_index
        expect(property.saved_transactions).not_to be_empty
        expect(property.tenants.first.saved_transactions).not_to be_empty
        expect(property.saved_transactions.pluck(:description).uniq).to eq(property.tenants.pluck(:name))
      end
    end

    it 'creates notifications' do
      expect(Notification.pluck(:subject).uniq).to eq(['rental_payment'])
      expect(Notification.pluck(:text).join).to include(*(properties.map(&:address) + tenants.map(&:name)))
    end

    context 'without notification flag' do
      let(:notification) { false }

      it 'do not creates notifications' do
        expect(Notification.all).to be_empty
      end
    end
  end
end
