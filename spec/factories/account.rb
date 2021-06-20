# frozen_string_literal: true

FactoryBot.define do
  factory :account do
    bank_id { Faker::Crypto.sha1 }
    association :user
  end
end
