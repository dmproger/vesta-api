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
  context 'specific builded user models' do
    # dynamic exapmles
    for model_name in MODELS
      class_eval <<-STR
        it "has no errors for #{ model_name } records list" do
          expect { #{ model_name }.all }.not_to raise_error
        end
      STR
    end
  end
end
