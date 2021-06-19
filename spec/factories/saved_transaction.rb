# frozen_string_literal: true

FactoryBot.define do
  factory :saved_transaction do
    amount { rand(100..1000) }
    association :user
  end
end
