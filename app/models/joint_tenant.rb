class JointTenant < ApplicationRecord
  belongs_to :tenant

  validates :name, presence: true
  validates :price, presence: true
end
