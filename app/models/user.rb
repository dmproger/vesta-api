# frozen_string_literal: true

class User < ActiveRecord::Base
  extend Devise::Models

  has_one_time_password length: 5 #OTP for phone number verification

  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :validatable
  include DeviseTokenAuth::Concerns::User

  validates :email, uniqueness: true
  validates :phone, uniqueness: true

  has_one :tink_access_token

  after_create :send_otp

  has_many :properties, dependent: :destroy
  has_many :tenants, through: :properties
  has_many :addresses, dependent: :destroy
  has_many :subscriptions, dependent: :destroy
  has_many :gc_events, dependent: :destroy
  has_many :accounts, dependent: :destroy
  has_many :saved_transactions, dependent: :destroy
  has_many :tink_credentials, through: :accounts
  has_many :expenses, dependent: :destroy

  has_many :associated_transactions, through: :properties

  def self.default_expenses
    Expense::DEFAULTS
  end

  def self.expenses_without_defaults
    expenses.map(&:name)
  end

  def self.expenses_with_defaults
    expenses_without_defaults + default_expenses
  end

  def non_archived_tenants_by(period:)
    tenants.where('(tenants.archived_at IS NULL OR tenants.archived_at > ?) AND (properties.archived_at IS NULL OR properties.archived_at > ?)', period, period)
        .joins(:property)
  end

  def subscription
    subscriptions.order(created_at: :desc).first
  end

  def active_subscription
    subscriptions.active.first
  end

  def replace_tink_access_token(attributes = nil)
    TinkAccessToken.transaction do
      tink_access_token&.destroy!
      create_tink_access_token!(attributes)
    end
  rescue ActiveRecord::RecordInvalid, ActiveRecord::RecordNotDestroyed
    tink_access_token # returns invalid object
  end

  def self.find_first_by_auth_conditions(warden_conditions)
    conditions = warden_conditions.dup
    where(phone: conditions[:phone]).first
  end

  def email_required?
    false
  end

  def email_changed?
    false
  end

  def will_save_change_to_email?
    false
  end

  def full_name
    "#{first_name} #{surname}"
  end

  def address_1
    addresses.first&.address
  end

  def post_code
    addresses.first&.post_code
  end

  def city
    addresses.first&.city
  end

  def get_market
    market || 'GB'
  end

  def get_locale
    locale || 'en_US'
  end

  def send_otp
    SendTwilioMessage.new("Your Vesta OTP is #{otp_code}", phone).call
  rescue StandardError => e
    puts "Unable to send OTP: #{e.message}"
  end

  def valid_tink_token(scopes:)
    GetTinkAccessToken.new(scopes: scopes, current_user: self).call
  end
end
