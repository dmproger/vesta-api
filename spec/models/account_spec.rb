require 'rails_helper'

# bundle exec rspec spec/models/account_spec.rb
RSpec.describe Account, type: :model do

  let(:account) { create(:account) }
  subject(:bank_id) { account.bank_id }
  subject(:account_number) { account.account_number }
  subject(:balance) { account.balance }
  subject(:available_credit) { account.available_credit }
  subject(:user) { account.user }
  subject(:is_closed) { account.is_closed }
  subject(:is_closed?) { account.is_closed? }
  subject(:saved_transactions) { account.saved_transactions }

  describe "Test account field values received from FactoryBot" do

    it "Checks for field classes" do
      expect(bank_id.class).to eq(String)
      expect(account_number.class).to eq(String)
      expect(balance.class).to eq(BigDecimal)
      expect(available_credit.class).to eq(BigDecimal)
      expect(user.class).to eq(User)
      expect(is_closed.class).to be_in([TrueClass, FalseClass])
    end

    describe "Closed account" do
      let(:account) { create(:account, is_closed: true) }
      it "Check closed methods" do
        expect(is_closed).to eq(true)
        expect(is_closed?).to eq(true)
      end
    end

    it "No transasctions by default" do
      expect(saved_transactions.count).to eq(0)
    end

    context "Account with default count transasctions:" do
      let(:account) { account_with_saved_transactions }
      it "Default count must be 5" do
        expect(saved_transactions.count).to eq(5)
      end
    end

    context "Account with custom count transasctions:" do
      let(:transactions_count) { 15 }
      let(:account) { account_with_saved_transactions saved_transactions_count: transactions_count }
      it "Count must be transactions_count" do
        expect(saved_transactions.count).to eq(transactions_count)
      end
    end
  end
end
