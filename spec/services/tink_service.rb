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

    before do
      # TODO
      # stub TinkService.get_tink_transactions
      # https://stackoverflow.com/questions/29111573/rspec-3-how-to-stub-methods-and-constants-from-code-we-have-yet-to-build-add
    end

    it 'get rental payments with notifications' do
      subject
    end
  end
end
