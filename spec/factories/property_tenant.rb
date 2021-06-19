# frozen_string_literal: true

FactoryBot.define do
  factory :property_tenant do
    association :property
    association :tenant
  end
end
