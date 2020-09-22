# frozen_string_literal: true

class User < ActiveRecord::Base
  extend Devise::Models

  has_one_time_password length: 4 #OTP for phone number verification

  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :validatable
  include DeviseTokenAuth::Concerns::User

  validates :email, uniqueness: true
  validates :phone, uniqueness: true

  after_create :send_otp

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

  private

  def send_otp
    # TODO: send OTP to user via SMS
    puts "Current OTP is: #{otp_code}"
  end
end
