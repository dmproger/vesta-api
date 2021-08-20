# frozen_string_literal: true

FactoryBot.define do
  factory :account do

    bank_id { SecureRandom.uuid }
    account_number { Faker::Bank.account_number }
    balance { Faker::Number.between(from: -999999.0, to: 999999.0).round(2) }
    available_credit { Faker::Number.between(from: 0.0, to: 999999.0).round(2) }
    association :user
    is_closed { Faker::Boolean.boolean(true_ratio: 0.2) }
  end
end
