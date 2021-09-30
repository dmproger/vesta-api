FactoryBot.define do
  factory :notification do
    user_id { nil }
    code { 1 }
    text { "MyText" }
    viewed { "" }
  end
end
