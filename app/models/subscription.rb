class Subscription < ApplicationRecord
  belongs_to :user

  INTERVAL_TYPES = %w[monthly yearly]

  validates :amount, presence: true
  validates :interval_unit, inclusion: {in: INTERVAL_TYPES}
  validates :month, inclusion: { in: Date::MONTHNAMES&.map {|v| v.downcase if v.present?} }, allow_blank: true

  scope :active, -> {where(is_active: true).where.not(external_sub_id: [nil, ''])}

  has_many :payments, dependent: :destroy


  def yearly?
    interval_unit == INTERVAL_TYPES.last
  end

  def monthly?
    interval_unit == INTERVAL_TYPES.first
  end
end
