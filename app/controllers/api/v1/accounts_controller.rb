class Api::V1::AccountsController < ApplicationController
  def index
    accounts = TinkAPI::V1::Client.new(current_user.valid_tink_token).accounts
    render json: {success: true, data: accounts}
  rescue RestClient::Exception => e
    render json: {success: false, message: e.message}
  end
end
