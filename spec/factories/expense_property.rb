FactoryBot.define do
  factory :expense_property do
    association :user
    association :property
    association :expense
  end
end
