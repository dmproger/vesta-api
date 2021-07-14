require 'rails_helper'

RSpec.describe Api::V1::PropertiesController do
  context 'expenses' do
    describe 'when GET /api/v1/properties/:id/expenses_summary' do
      subject(:send_request) { get "/api/v1/properties/#{ property.id }/expenses_summary", params: params, headers: headers }

      let!(:user) { create(:user) }
      let!(:account) { create(:account) }
      let!(:transactions) { create_list(:saved_transaction, 3, user: user, account: account, transaction_date: Date.current - 1.day) }
      let!(:expenses) { create_list(:expense, 3, user: user) }
      let!(:property) { create(:property, user: user) }

      let!(:headers) { auth_headers }

      let!(:period) { (Date.current - 2.days)..(Date.current) }
      let!(:params) { { start_date: period.first.strftime('%F'), end_date: period.last.strftime('%F') } }

      before do
        sign_in(user)
        expenses.each_with_index do |expense, i|
          property.assign_expense(expense, transactions[i])
        end
      end

      it 'returns expenses summary' do
        subject
        expect(body).to include(transactions.map(&:amount).sum.to_s)
      end
    end

    describe 'when GET /api/v1/properties/expenses_summary' do
      subject(:send_request) { get "/api/v1/properties/expenses_summary", params: params, headers: headers }

      let!(:user) { create(:user) }
      let!(:property) { create(:property, user: user) }
      let!(:headers) { auth_headers }
      let!(:period) { (Date.current - 2.days)..(Date.current) }
      let!(:params) { { start_date: period.first.strftime('%F'), end_date: period.last.strftime('%F') } }

      before { sign_in(user) }

      it 'returns expenses' do
        # TODO
      end
    end
  end

  context 'collected' do
    describe 'when GET /api/v1/properties/:id/collected_summary', :request do
      subject(:send_request) { get "/api/v1/properties/#{ property.id }/collected_summary", params: params, headers: headers }

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
      let!(:params) { { start_date: period.first.strftime('%F'), end_date: period.last.strftime('%F') } }

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
end
