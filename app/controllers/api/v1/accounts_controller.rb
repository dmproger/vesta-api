class Api::V1::AccountsController < ApplicationController
  def index
    accounts = TinkAPI::V1::Client.new(current_user.valid_tink_token).accounts
    render json: {success: true, data: accounts}
  rescue RestClient::Exception => e
    render json: {success: false, message: e.message}
  end

  def linking_code
    user_auth_code = current_user.tink_auth_code.presence || GetAccountLinkingCode.new(current_user).call

    render json: {success: true, message: 'tink link auth code', data: {code: user_auth_code}}
  rescue StandardError => e
    render json: {success: false, message: e.message, data: nil}
  end
end
