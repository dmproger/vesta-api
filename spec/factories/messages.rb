FactoryBot.define do
  factory :message do
    association :user
    reciver { nil }
    kind { 1 }
    topic { Faker::Movie.title }
    text { Faker::Book.title }
    images { nil }
    viewed { false }
    helpful { false }
    grade { nil }
  end
end
