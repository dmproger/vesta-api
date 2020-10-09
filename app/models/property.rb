class Property < ApplicationRecord
  belongs_to :user

  has_many :tenants, dependent: :destroy

  validates :address, presence: true
  validates :city, presence: true
  validates :country, presence: true
  validates :post_code, presence: true

  scope :non_archived, -> {where(is_archived: false)}
  scope :archived, -> {where(is_archived: true)}

  def active_tenant
    tenants.non_archived.where(is_active: true).first
  end

  def latest_tenant
    tenants.non_archived.order(created_at: :desc).first
  end
end
