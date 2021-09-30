# frozen_string_literal: true

FactoryBot.define do
  factory :saved_transaction do
    amount { rand(100..1000) }
    category_type { 'INCOME' }
    association :user
    association :account
    transaction_date { Date.current }
    description { Faker::Name.first_name }
  end
end
