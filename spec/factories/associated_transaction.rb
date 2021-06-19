# frozen_string_literal: true

FactoryBot.define do
  factory :associated_transaction do
    association :saved_transaction
    association :property_tenant
  end
end
