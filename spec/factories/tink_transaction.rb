# frozen_string_literal: true

#
# example see at support/data/tink_transaction.yml
#
FactoryBot.define do
  factory :tink_transaction, class: Array do
    timestamp { Time.current }
    score { 0.0 }
    id { Faker::Crypto.sha1 }
    amount { 100 }
    category_type { 'INCOME' }
    description { '' }
    date { Time.current }
    pending { true }
    notes { '' }
    user_modified { false }

    initialize_with do
      {
        timestamp: attributes[:timestamp].to_i,
        score: attributes[:score],
        transaction: {
          amount: attributes[:amount],
          categoryType: attributes[:category_type],
          date: attributes[:date].to_i,
          originalDescription: attributes[:description],
          id: attributes[:id],
          notes: attributes[:notes],
          pending: attributes[:pending],
          userModified: attributes[:user_modified]
        }
      }.to_json
    end
  end
end
