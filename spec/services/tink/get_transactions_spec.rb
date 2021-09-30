return unless ENV['TINKTEST']

require 'rails_helper'

MODELS = [Account, SavedTransaction, Property, Tenant, PropertyTenant]
require_relative '../../support/manual/test_user_data'


RSpec.describe TinkService do
  let(:user) { User.find_by(phone: ENV['USER']) || USER }
  let(:account) { ACCOUNT_WITH_TRANSACTIONS }
 
  describe '.get_tink_transactions' do
    subject { described_class.get_tink_transactions(user, account) }

    let(:transactions) { subject.map { |e| e["transaction"] } }
    let(:income) { transactions.dup.keep_if { |t| t["categoryType"] == 'INCOME' } }
    let(:expenses) { transactions.dup.keep_if { |t| t["categoryType"] == 'EXPENSES' } }

    before { subject }

    it 'byebug it' do
      byebug
    end
  end
end
