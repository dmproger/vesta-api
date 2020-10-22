class Property < ApplicationRecord
  belongs_to :user

  has_many :tenants, dependent: :destroy

  has_many :property_tenant_transactions, dependent: :destroy
  has_many :saved_transactions, through: :property_tenant_transactions,
           class_name: 'SavedTransaction'

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
