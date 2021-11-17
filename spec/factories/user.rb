# frozen_string_literal: true

FactoryBot.define do
  factory :user do
    first_name { Faker::Name.first_name }
    surname { Faker::Name.middle_name }
    email { Faker::Internet.email }
    uid { email }
    phone { Faker::PhoneNumber.cell_phone_in_e164 }
    password { Faker::Internet.password }
    notification { { 'late' => { 'interval' => 30, 'time' => '12:00', 'enable' => false } } }
  end

  factory :tink_user, parent: :user do
    tink_user_id { Faker::Crypto.sha1 }
    tink_auth_code { Faker::Crypto.sha1 }
  end
end
