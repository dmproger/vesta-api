class GetTinkAccessToken
  attr_reader :scopes, :current_user

  def initialize(scopes:, current_user:)
    @scopes = scopes
    @current_user = current_user
  end

  def call
    grant_access_token = TinkAPI::V1::Client.new.client_access_token_with_grant
    raise 'unable to get grant access token' if grant_access_token.dig(:access_token).blank?

    grant_auth_code = TinkAPI::V1::Client.new.grant_authorization(tink_user_id: current_user.tink_user_id,
                                                                  current_user: current_user,
                                                                  grant_access_token: grant_access_token.dig(:access_token),
                                                                  scopes: scopes)
    raise 'unable to get grant auth code' if grant_auth_code.dig(:code).blank?

    access_token_response = TinkAPI::V1::Client.new.retrieve_access_tokens(auth_code: grant_auth_code.dig(:code),
                                                                           scopes: scopes)
    raise 'unable to get access token' if access_token_response.dig(:access_token).blank?

    access_token_response.dig(:access_token)
  end
end
