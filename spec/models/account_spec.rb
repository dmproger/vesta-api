require 'rails_helper'

# bundle exec rspec spec/models/account_spec.rb
RSpec.describe Account, type: :model do

  context "TODO" do
    let(:account) { create(:account) }

    it "TODO" do
      print 'account.available_credit: '; puts account.available_credit
      expect(account.available_credit).to be > 0
    end
  end
end
