FactoryBot.define do
  factory :expense do
    association :user
    name { Faker::Crypto.sha1 }
  end
end
