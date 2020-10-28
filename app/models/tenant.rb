class Tenant < ApplicationRecord
  belongs_to :property

  scope :active, -> { where(is_active: true) }
  scope :non_archived, -> { where(is_archived: false) }
  scope :within, -> (period) {where("start_date <= ? AND end_date >= ?", period.end_of_month, period.end_of_month)}
  scope :monthly, -> {where(payment_frequency: 'monthly')}
  scope :annually, -> {where(payment_frequency: 'annually')}

  PAYMENT_FREQUENCIES = %w[monthly quarterly bi-annually annually]
  PAYEE_TYPES = %w[tenant agent joint]

  validates :payment_frequency, inclusion: {in: PAYMENT_FREQUENCIES}
  validates :payee_type, inclusion: {in: PAYEE_TYPES}
  validates :name, presence: true, if: :tenant_payee?
  validates :price, presence: true, numericality: {greater_than_or_equal_to: 0}
  validates :phone, presence: true, unless: :tenant_payee?
  validates :start_date, date: {after_or_equal_to: Proc.new { Date.current }, before: :end_date}, on: :create
  validates :end_date, date: {after: :start_date}, on: :create
  validates :agent_name, presence: true, if: :agent_payee?

  has_one_attached :tenancy_agreement
  has_one_attached :agency_agreement

  has_many :joint_tenants, dependent: :destroy
  has_many :property_tenant_transactions
  has_many :saved_transactions, through: :property_tenant_transactions, class_name: 'SavedTransaction'

  accepts_nested_attributes_for :joint_tenants, allow_destroy: true

  after_create :setup_expiry, if: :is_active
  after_update :setup_expiry, if: :is_active

  validate :conflict

  def conflict
    active_tenant = property.tenants.active.where.not(id: id).first
    if active_tenant.present? && is_active
      errors.add(:is_active, ': there can only be one active tenant')
    end

    if start_date.present? &&
        active_tenant.present? &&
        active_tenant.end_date > start_date

      errors.add(:conflict, ": start_date should be grater then conflicting tenant's end_date (#{active_tenant.end_date})")
    end
  end

  def tenancy_agreement_url
    if tenancy_agreement.attached?
      {url: Rails.application.routes.url_helpers.rails_blob_url(tenancy_agreement, disposition: "attachment")}
    end
  end

  def agency_agreement_url
    if agency_agreement.attached?
      {url: Rails.application.routes.url_helpers.rails_blob_url(agency_agreement, disposition: "attachment")}
    end
  end

  def deactivate
    # update_columns is used to avoid infinite callback loop
    self.update_columns(is_active: false, expiry_job_id: nil)
  end

  def setup_expiry
    Delayed::Job.find_by(id: self.expiry_job_id).destroy if self.expiry_job_id.present?
    job = self.delay(run_at: self.end_date.end_of_day).deactivate

    # update_columns is used to avoid infinite callback loop
    self.update_column(:expiry_job_id, job.id)
  end

  private

  def joint_payee?
    payee_type == PAYEE_TYPES.third
  end

  def agent_payee?
    payee_type == PAYEE_TYPES.second
  end

  def tenant_payee?
    payee_type == PAYEE_TYPES.first
  end
end
