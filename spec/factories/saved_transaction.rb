# frozen_string_literal: true

FactoryBot.define do
  factory :saved_transaction do
    amount { rand(100..1000) }
    category_type { 'INCOME' }
    association :user
    transaction_date { Date.current }
  end
end
