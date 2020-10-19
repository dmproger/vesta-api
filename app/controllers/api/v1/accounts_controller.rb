class Api::V1::AccountsController < ApplicationController
  def index
    accounts = TinkAPI::V1::Client.new(current_user.valid_tink_token(scopes: 'accounts:read')).accounts
    render json: {success: true, message: 'accounts', data: accounts}
  rescue RestClient::Exception => e
    render json: {success: false, message: e.message, data: nil}
  end

  def linking_code
    user_auth_code = GetAccountLinkingCode.new(current_user).call

    url = "https://link.tink.com/1.0/credentials/add?client_id=#{ENV['TINK_CLIENT_ID']}"\
          "&scope=transactions:read,identity:read&redirect_uri=#{params[:callback_url].presence}"\
          "&authorization_code=#{user_auth_code}"

    url << '&test=true' if !!ENV['SANDBOX_ENV']

    render json: {success: true, message: 'tink link auth code', data: {code: user_auth_code, url: url}}
  rescue StandardError => e
    render json: {success: false, message: e.message, data: nil}
  end
end
