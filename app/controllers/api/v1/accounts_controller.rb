class Api::V1::AccountsController < ApplicationController
  def index
    accounts = TinkAPI::V1::Client.new(current_user.tink_token).accounts
    render json: {success: true, data: accounts}
  end
end
