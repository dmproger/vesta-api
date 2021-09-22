# frozen_string_literal: true

FactoryBot.define do
  factory :tenant do
    name { Faker::Name.first_name }
    agent_name { Faker::Name.first_name }
    price { rand(100..1000) }
    start_date { Time.current - 1.month }
    end_date { Time.current + 1.month }
  end
end
