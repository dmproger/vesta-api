class Api::V1::TinkTokensController < ApplicationController

  def create
    response = TinkAPI::V1::Client.new.retrieve_access_tokens(auth_code: create_params.dig(:code))

    current_user.replace_tink_access_token(response)

    render json: {success: true, message: 'token created successfully'}
  rescue RestClient::Exception, StandardError => e
    render json: {success: false, message: e.message}
  end

  private

  def create_params
    params.require(:auth_code).permit(:code, :credentialsId, :state)
  end
end
