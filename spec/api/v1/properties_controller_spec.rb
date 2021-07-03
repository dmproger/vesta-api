require 'rails_helper'

RSpec.describe Api::V1::PropertiesController do
  context 'expenses' do
    describe 'when GET /api/v1/properties/:id/expenses' do
      subject(:send_request) { get "/api/v1/properties/#{ property.id }/expenses", params: params, headers: headers }

      let!(:user) { create(:user) }
      let!(:property) { create(:property, user: user) }
      let!(:headers) { auth_headers }

      before { sign_in(user) }

      it 'returns expenses' do
        subject
        expect(body).to include('water')
      end
    end

    describe 'when GET /api/v1/properties/expenses' do
      subject(:send_request) { get "/api/v1/properties/expenses", params: params, headers: headers }

      let!(:user) { create(:user) }
      let!(:property) { create(:property, user: user) }
      let!(:headers) { auth_headers }

      before { sign_in(user) }

      it 'returns expenses' do
        subject
        expect(body).to include('water')
      end
    end
  end
  describe 'when GET /api/v1/properties/:id/symmary', :request do
    subject(:send_request) { get "/api/v1/properties/#{ property.id }/summary", params: params, headers: headers }

    let!(:user) { create(:user) }
    let!(:account) { create(:account) }
    let!(:tenant) { create(:tenant) }
    let!(:property) { create(:property, user: user) }
    let!(:property_tenant) { create(:property_tenant, property: property, tenant: tenant) }
    let!(:saved_transactions) { create_list(:saved_transaction, rand(3..4), user: user, account: account, transaction_date: Date.current - 1.day) }
    let!(:other_saved_transactions) { create_list(:saved_transaction, rand(3..4), user: user, account: account, transaction_date: Date.current + 1.day) }
    let!(:associated_transactions) do
      (saved_transactions + other_saved_transactions).each do |saved_transaction|
        create(:associated_transaction, saved_transaction: saved_transaction, property_tenant: property_tenant)
      end
    end

    let!(:period) { (Date.current - 2.days)..(Date.current) }
    let!(:summary) do
      user.
        saved_transactions.income.
        joins(associated_transaction: :property).
        where(property_tenants: { property: property }).
        where(transaction_date: period).
        sum(:amount)
    end
    let!(:other_summary) do
      user.
        saved_transactions.income.
        joins(associated_transaction: :property).
        where(property_tenants: { property: property }).
        sum(:amount)
    end

    let!(:headers) { auth_headers }
    let!(:params) {
      {
        start_date: period.first.strftime('%F'),
        end_date: period.last.strftime('%F')
      }
    }

    before { sign_in(user) }

    it 'has symmary of collected values' do
      subject
      expect(summary).not_to be(0)

      value = JSON.parse(body)['data']
      expect(value).to eq(summary.to_f.round(2))
      expect(value).not_to eq(other_summary.to_f.round(2))
    end
  end
end
