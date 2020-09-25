class RefreshTinkToken
  attr_reader :tink_access_token

  def initialize(tink_access_token)
    @tink_access_token = tink_access_token
  end

  def call
    response = TinkAPI::V1::Client.new.refresh_access_tokens(refresh_token: tink_access_token.refresh_token)
    tink_access_token.user.replace_tink_access_token(response)
  end
end
