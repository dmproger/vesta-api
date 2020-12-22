class TinkHooksController < ApplicationController
  skip_before_action :authenticate_user!

  # TODO: we don't need this callback when iOS app is ready to do this for us
  # to receive authorization token from tink
  def callback
    # response = TinkAPI::V1::Client.new.retrieve_access_tokens(auth_code: params[:code])
    render json: {success: true, message: nil, data: params}
  rescue RestClient::Exception => e
    render json: {success: false, message: e.message}
  end
end
