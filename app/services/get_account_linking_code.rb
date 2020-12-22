class GetAccountLinkingCode
  attr_reader :current_user

  def initialize(current_user)
    @current_user = current_user
  end

  def call
    tink_user_id = current_user.tink_user_id.presence || create_tink_user


    grant_token_response = TinkAPI::V1::Client.new.client_access_token_with_grant
    grant_token = grant_token_response.dig(:access_token)
    raise 'unable to get grant token from tink' if grant_token.blank?

    delegate_response = TinkAPI::V1::Client.new.delegate_grant_auth(tink_user_id: tink_user_id,
                                                                    grant_access_token: grant_token,
                                                                    current_user: current_user)
    user_auth_code = delegate_response.dig(:code)
    raise 'unable to get auth code from tink' if user_auth_code.blank?

    raise 'unable to save auth code' unless current_user.update(tink_auth_code: user_auth_code)

    user_auth_code
  end

  private

  def create_tink_user
    response = TinkAPI::V1::Client.new.client_access_token
    access_token = response.dig(:access_token)
    raise 'unable to get access token' if access_token.blank?

    create_user_response = TinkAPI::V1::Client.new.create_tink_user(client_access_token: access_token,
                                                                    locale: current_user.get_locale,
                                                                    market: current_user.get_market)

    tink_user_id = create_user_response.dig(:user_id)
    raise 'unable to create user on tink' if tink_user_id.blank?
    raise 'unable to save tink user id' unless current_user.update(tink_user_id: tink_user_id)

    tink_user_id
  end
end