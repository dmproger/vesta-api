require 'rails_helper'

RSpec.describe Api::V1::PropertiesController do
  describe 'when GET /api/v1/properties/:id/symmary' do
    subject(:send_request) { get "/api/v1/properties/#{ property.id }/summary", params: params, headers: headers }

    let!(:user) { create(:user) }
    let!(:account) { create(:account) }
    let!(:tenant) { create(:tenant) }
    let!(:property) { create(:property, user: user) }
    let!(:property_tenant) { create(:property_tenant, property: property, tenant: tenant) }
    let!(:saved_transactions) { create_list(:saved_transaction, rand(3..4), user: user, account: account) }
    let!(:associated_transactions) do
      saved_transactions.each do |saved_transaction|
        create(:associated_transaction, saved_transaction: saved_transaction, property_tenant: property_tenant)
      end
    end
    let(:summary) do
      user.
        saved_transactions.
        joins(associated_transaction: :property).
        where(property_tenants: { property: property }).
        sum(:amount)
    end

    before do
      sign_in(user)
      summary
    end

    it 'has symmary of collected values' do
      # TODO
    end
  end
end
