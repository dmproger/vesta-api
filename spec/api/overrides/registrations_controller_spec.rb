require 'rails_helper'

RSpec.describe Overrides::RegistrationsController do
  context 'change user credentials' do

    # Исходные данные это пользователь и хэш для изменений, параметры и
    # заголовок генерим из них.
    subject {
      put '/api/v1/auth',
        headers: user.create_new_auth_token,
        params: credentials.merge({phone: user.phone})
    }

    def to_credentials(user)
      user.attributes.symbolize_keys.slice(*described_class::CREDENTIALS_PARAMS)
    end

    let!(:user) { create(:user) }
    # нельзя сохранять второго пользователя - лишние данные, и ошибка из-за
    # дублирования email при изменеии у первого пользователья на email
    # второго, поэтому `build`.
    let!(:credentials) { to_credentials(build(:user)) }

    before do
      sign_in(user)
    end

    it 'change user credentials' do

      expect(to_credentials(user)).not_to eq(credentials)

      subject
      expect(response).to be_successful

      expect(to_credentials(user.reload)).to eq(credentials)
    end
  end
end
