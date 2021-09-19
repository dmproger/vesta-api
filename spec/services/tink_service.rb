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

RSpec.describe TinkService do
  describe '.get_rental_payment' do
    subject { described_class.get_rental_payment(users) }

    let(:users) { [USER] }
    let(:tink_transactions) { build_list(:tink_transaction, rand(3..4)) }

    before do
      # TODO
      # https://stackoverflow.com/questions/29111573/rspec-3-how-to-stub-methods-and-constants-from-code-we-have-yet-to-build-add
    end

    it 'get rental payments with notifications' do
      subject
    end
  end
end
