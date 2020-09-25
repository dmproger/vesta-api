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

  def send_otp
    SendTwilioMessage.new("Your Vesta OTP is #{otp_code}", phone).call
  rescue StandardError => e
    puts "Unable to send OTP: #{e.message}"
  end

  def valid_tink_token
    refresh_tink_token if tink_access_token.is_expired?
    tink_access_token.access_token
  end

  def refresh_tink_token
    RefreshTinkToken.new(tink_access_token).call
  end
end
