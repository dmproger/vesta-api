FactoryBot.define do
  factory :message do
    user { nil }
    reciver { "MyString" }
    topic { "MyString" }
    text { "MyText" }
    images { nil }
    viewed { false }
    helpful { false }
    grade { 1 }
  end
end
