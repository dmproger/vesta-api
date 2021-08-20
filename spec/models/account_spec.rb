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

  context "Test account field values received from FactoryBot" do

    it "Checks for field classes" do
      expect(bank_id.class).to eq(String)
      expect(account_number.class).to eq(String)
      expect(balance.class).to eq(BigDecimal)
      expect(available_credit.class).to eq(BigDecimal)
      expect(user.class).to eq(User)
      expect(is_closed.class).to be_in([TrueClass, FalseClass])
    end

    let(:account) { create(:account, is_closed: false) }

    it "Checks for field classes" do
      expect(is_closed.class).to eq(FalseClass)
    end
  end
end
