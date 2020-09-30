# frozen_string_literal: true

class User < ActiveRecord::Base
  extend Devise::Models

  has_one_time_password length: 5 #OTP for phone number verification

  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :validatable
  include DeviseTokenAuth::Concerns::User

  validates :email, uniqueness: true
  validates :phone, uniqueness: true

  after_create :send_otp

  has_many :properties, dependent: :destroy
  has_many :tenants, through: :properties
  has_many :addresses, dependent: :destroy

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

  def send_otp
    SendTwilioMessage.new("Your Vesta OTP is #{otp_code}", phone).call
  rescue StandardError => e
    puts "Unable to send OTP: #{e.message}"
  end
end
