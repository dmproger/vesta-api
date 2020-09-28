class Property < ApplicationRecord
  belongs_to :user

  has_many :tenants, dependent: :destroy

  validates :address, presence: true
  validates :city, presence: true
  validates :country, presence: true
  validates :post_code, presence: true
end
