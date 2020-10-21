class Account < ApplicationRecord
  belongs_to :user

  has_many :saved_transactions, dependent: :destroy
end
