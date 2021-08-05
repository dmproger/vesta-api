require 'rails_helper'

MODELS = %w[
  User::All
  User::Operation::Reset
  User::Trouble::NoPhone
  User::Trouble::NoPhoneConfirmed
  User::Trouble::NoProperty
  User::Trouble::NoTenant
  User::Trouble::NoTinkLink
  User::Trouble::NoBankAccount
  User::Success::WithPhone
  User::Success::WithPhoneConfirmed
  User::Success::WithProperty
  User::Success::WithTenant
  User::Success::WithTinkLink
  User::Success::WithBankAccount
]

RSpec.describe User do
  # dynamic exapmles
  for model in MODELS
    it "have no error on for #{ model } results" do
      expect { model.constantize.all }.not_to raise_error
    end
  end
end
