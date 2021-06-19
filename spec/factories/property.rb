# frozen_string_literal: true

FactoryBot.define do
  factory :property do
    association :user
    address { Faker::Name.first_name }
    city { Faker::Name.first_name }
    country { Faker::Name.first_name }
    post_code { Faker::Name.first_name }
  end
end
