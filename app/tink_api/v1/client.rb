# Note: restart the server whenever you make changes to this file

module TinkAPI
  module V1
    class Client
      API_ENDPOINT = 'https://api.tink.com/api/v1'.freeze

      attr_reader :access_token

      def initialize(access_token = nil)
        @access_token = access_token
      end

      def retrieve_access_tokens(auth_code:)
        response = RestClient.post "#{API_ENDPOINT}/oauth/token",
                                   {
                                       code: auth_code,
                                       client_id: ENV['TINK_CLIENT_ID'],
                                       client_secret: ENV['TINK_CLIENT_SECRET'],
                                       grant_type: 'authorization_code  '
                                   }

        JSON.parse(response.body).symbolize_keys
      end

      def accounts
        response = RestClient.get "#{API_ENDPOINT}/accounts/list",
                                   {
                                       authorization: "Bearer #{access_token}"
                                   }
        JSON.parse(response.body).symbolize_keys
      end
    end
  end
end