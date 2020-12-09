class Api::V1::AccountsController < ApplicationController
  before_action :verify_account_linked?, only: :index

  def index
    accounts = TinkAPI::V1::Client.new(current_user.valid_tink_token(scopes: 'accounts:read')).accounts
    render json: {success: true, message: 'accounts',
                  data: {accounts: persist_accounts(accounts),
                         subscription: current_user.active_subscription}}
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

  private

  def verify_account_linked?
    render json: {success: true, message: 'please link your account first!', data: nil} if currnet_user.tink_user_id.blank?
  end

  def persist_accounts(accounts)
    PersistAccount.new(accounts.dig(:accounts), current_user).call
  end
end
