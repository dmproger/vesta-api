class Subscription < ApplicationRecord
  belongs_to :user

  INTERVAL_TYPES = %w[monthly annually]

  validates :amount, presence: true
  validates :payment_interval, inclusion: {in: INTERVAL_TYPES}
end
