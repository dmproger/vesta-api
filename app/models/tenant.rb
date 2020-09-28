class Tenant < ApplicationRecord
  belongs_to :property

  PAYMENT_FREQUENCIES = %w[monthly quarterly bi-annually annually]

  validates :payment_frequency, inclusion: {in: PAYMENT_FREQUENCIES}
  validates :name, presence: true
  validates :price, presence: true, numericality: {greater_than_or_equal_to: 0}
  validates :phone, presence: true
  validates :start_date, date: {after_or_equal_to: Proc.new { Date.current }, before: :end_date}
  validates :end_date, date: {after: :start_date}

  has_one_attached :tenancy_agreement
  has_one_attached :agency_agreement

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
end
