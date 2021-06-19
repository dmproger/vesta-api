require 'rails_helper'

RSpec.describe Api::V1::HomeController do
  describe 'when GET /api/v1/home/symmary' do
    subject(:send_request) { get '/api/v1/home/summary', params: params, headers: headers }

    let!(:user) { create(:user) }
    let!(:tenant) { create(:tenant) }
    let!(:property) { create(:property, user: user) }
    let!(:property_tenant) { create(:property_tenant, property: property, tenant: tenant) }
    let!(:saved_transactions) { create_list(:saved_transaction, rand(3..4), user: user) }
    let(:associated_transactions) do
      saved_transactions.each do |saved_transaction|
        create(:associated_transaction, saved_transaction: saved_transaction)
      end
    end
    let!(:summary) { saved_transactions.joins(:associated_transactions).sum(:amount) }

    before { sign_in(user) }

    it 'has symmary of collected values' do
      byebug
    end
  end
end
