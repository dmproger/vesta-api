class Property < ApplicationRecord
  belongs_to :user

  has_many :tenants, dependent: :destroy

  has_many :property_tenants, dependent: :destroy
  has_many :associated_transactions, through: :property_tenants
  has_many :saved_transactions, through: :associated_transactions,
           class_name: 'SavedTransaction'

  has_many :expense_properties
  has_many :expenses, through: :expense_properties
  has_many :expense_transactions, through: :expense_properties,
    source: :saved_transaction

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

  def assign_expense(expense, transaction)
    transaction.assign_expense(expense, self)
  end

  def unassign_expense(transaction)
    transaction.unassign_expense
  end
end
