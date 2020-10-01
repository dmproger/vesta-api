class JointTenant < ApplicationRecord
  belongs_to :tenant

  validates :name, presence: true
  validates :price, presence: true
  validates :day_of_month, presence: true
end
