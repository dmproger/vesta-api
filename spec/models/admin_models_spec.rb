require 'rails_helper'

RSpec::Expectations.configuration.on_potential_false_positives = :nothing

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
        it "has no errors for #{ model_name } records list" do
          expect { model_name.constantize.all }.not_to raise_error
        end
    end
  end
end
