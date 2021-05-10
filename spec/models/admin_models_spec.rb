require 'rails_helper'

RSpec.describe User do
  context 'prefiltered user models' do
    it 'enable user all' do
      expect { User::All.all }.not_to raise_error
    end

    it 'enable user bank many' do
      expect { User::BankMany.all }.not_to raise_error
    end

    it 'enable user bank single' do
      expect { User::BankSingle.all }.not_to raise_error
    end

    it 'enable user phone not confirmed' do
      expect { User::PhoneNotConfirmed.all }.not_to raise_error
    end

    it 'enable user property single' do
      expect { User::PropertySingle.all }.not_to raise_error
    end

    it 'enable user property many' do
      expect { User::PropertyMany.all }.not_to raise_error
    end

    it 'enable user property not added' do
      expect { User::PropertyNotAdded.all }.not_to raise_error
    end

    it 'enable user tink not authenticated' do
      expect { User::TinkNotAuthenticated.all }.not_to raise_error
    end

    it 'enable user tink not registered' do
      expect { User::TinkNotRegistered.all }.not_to raise_error
    end

    it 'enable user tink registered' do
      expect { User::TinkRegistered.all }.not_to raise_error
    end
  end
end
