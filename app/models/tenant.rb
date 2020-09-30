class Tenant < ApplicationRecord
  belongs_to :property

  scope :active, -> { where(is_active: true) }

  PAYMENT_FREQUENCIES = %w[monthly quarterly bi-annually annually]

  validates :payment_frequency, inclusion: {in: PAYMENT_FREQUENCIES}
  validates :name, presence: true
  validates :price, presence: true, numericality: {greater_than_or_equal_to: 0}
  validates :phone, presence: true
  validates :start_date, date: {after_or_equal_to: Proc.new { Date.current }, before: :end_date}
  validates :end_date, date: {after: :start_date}

  has_one_attached :tenancy_agreement
  has_one_attached :agency_agreement

  after_create :setup_expiry, if: :is_active
  after_update :setup_expiry, if: :is_active

  validate :conflict

  def conflict
    active_tenant = property.tenants.active.where.not(id: id).first
    if active_tenant.present? && is_active
      errors.add(:is_active, ': there can only be one active tenant' )
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
end
