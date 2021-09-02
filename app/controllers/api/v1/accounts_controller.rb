require_relative '../../../tink_api/v1/client'
require_relative '../../../services/get_account_linking_code'

class Api::V1::AccountsController < ApplicationController
  before_action :verify_account_linked?, only: :index
  before_action :set_account, only: [:update_credentials, :refresh_credentials, :renew_credentials_link]

  def index
    accounts = TinkAPI::V1::Client.new(current_user.valid_tink_token(scopes: 'accounts:read')).accounts
    @accounts = persist_accounts(accounts)
    @accounts = test_accounts_resolve if @accounts.none?
  rescue RestClient::Exception => e
    render json: {success: false, message: e.message, data: nil}
  end

  def linking_code
    user_auth_code = GetAccountLinkingCode.new(current_user).call

    url = "https://link.tink.com/1.0/credentials/add?client_id=#{ENV['TINK_CLIENT_ID']}"\
          "&scope=transactions:read,identity:read&redirect_uri=#{params[:callback_url].presence}"\
          "&authorization_code=#{user_auth_code}"\
          "&market=#{current_user.get_market || 'GB'}&locale=#{current_user.get_locale}"

    url << '&test=true' if ENV['SANDBOX_ENV'] == 'true'

    render json: {success: true, message: 'tink link auth code', data: {code: user_auth_code, url: url}}
  rescue StandardError => e
    render json: {success: false, message: e.message, data: nil}
  end

  def renew_credentials_link
    user_auth_code = GetAccountLinkingCode.new(current_user).call

    url = "https://link.tink.com/1.0/"\
          "credentials/#{open_banking? ? AUTHENTICATE_ENDPOINT : REFRESH_ENDPOINT}?"\
          "client_id=#{ENV['TINK_CLIENT_ID']}"\
          "&redirect_uri=#{params.dig(:callback_url)}"\
          "&credentials_id=#{@account.credentials_id}"\
          "&authorization_code=#{user_auth_code}"\
          "#{open_banking? ? '' : '&authenticate=true'}"

    url << '&test=true' if ENV['SANDBOX_ENV'] == 'true'

    render json: {success: true, message: 'tink link refresh credentials', data: {code: user_auth_code, url: url}}
  end

  def refresh_credentials
    TinkAPI::V1::Client.new(current_user.valid_tink_token(scopes: 'credentials:refresh'))
                       .refresh_credentials(id: @account.credentials_id)

  end

  def update_credentials
    credential = TinkAPI::V1::Client.new(current_user.valid_tink_token(scopes: 'credentials:read'))
                                    .get_credentials(id: @account.credentials_id)

    if @account.tink_credential&.update(credential)
      render json: {success: true, message: 'credentials updated', data: nil}
    else
      render json: {success: false, message: 'credentials update failed', data: nil}
    end
  end

  private

  REFRESH_ENDPOINT='refresh'.freeze
  AUTHENTICATE_ENDPOINT='authenticate'.freeze
  def open_banking?
    @account.tink_credential&.provider_name&.include?('open-banking')
  end

  def set_account
    @account = current_user.accounts.find_by(id: params[:id])

    render json: {
      success: false,
      message: 'invalid account id',
      data: nil
    } if @account.blank?
  end

  def verify_account_linked?
    render json: {success: true, message: 'please link your account first!', data: nil} if current_user.tink_user_id.blank?
  end

  def persist_accounts(accounts)
    PersistAccount.new(accounts.dig(:accounts), current_user).call
  end

  def test_accounts_resolve
    holder_name = User::Test::Builder::ACCOUNT_HOLDERNAME
    current_user.accounts.map { |account| account.holder_name == holder_name ? account : nil }.compact
  end
end
