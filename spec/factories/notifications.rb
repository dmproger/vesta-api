FactoryBot.define do
  factory :notification do
    association :user
    subject { :rental_payment }
    title { Faker::Movie.title }
    text { Faker::Book.title }
    viewed { false }
  end
end
