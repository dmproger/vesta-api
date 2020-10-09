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
                                       grant_type: 'authorization_code'
                                   }

        JSON.parse(response.body).symbolize_keys
      end

      def refresh_access_tokens(refresh_token:)
        response = RestClient.post "#{API_ENDPOINT}/oauth/token",
                                   {
                                       refresh_token: refresh_token,
                                       client_id: ENV['TINK_CLIENT_ID'],
                                       client_secret: ENV['TINK_CLIENT_SECRET'],
                                       grant_type: 'refresh_token'
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

      #  PERMANENT USERS FLOW
      # 1-Create a permanent user
      # 2-Generate a user authorization code (sent the code to app-client)
      # 3-Launch Tink Link with the user authorization code (Done on app side)

      # 1-Create a permanent user

      # 1.1 Get Client Access Token
      def client_access_token
        response = RestClient.post "#{API_ENDPOINT}/oauth/token",
                                   {
                                       client_id: ENV['TINK_CLIENT_ID'],
                                       client_secret: ENV['TINK_CLIENT_SECRET'],
                                       grant_type: 'client_credentials',
                                       scope: 'user:create'
                                   }

        JSON.parse(response.body).symbolize_keys
      end

      # 1.2 Create User
      def create_tink_user(client_access_token:, locale:, market:)
        response = RestClient.post "#{API_ENDPOINT}/user/create",
                                   {
                                       locale: locale || 'en_US',
                                       market: market || 'SE'
                                   },
                                   {
                                       'Authorization' => "Bearer #{client_access_token}"
                                   }

        JSON.parse(response.body).symbolize_keys
      end

      # 2-Generate a user authorization code

      # 2.1 Get Access token with scope authorization:grant
      def client_access_token_with_grant
        response = RestClient.post "#{API_ENDPOINT}/oauth/token",
                                   {
                                       client_id: ENV['TINK_CLIENT_ID'],
                                       client_secret: ENV['TINK_CLIENT_SECRET'],
                                       grant_type: 'client_credentials',
                                       scope: 'authorization:grant'
                                   }


        JSON.parse(response.body).symbolize_keys
      end

      # 2.2 Delegate the authorization:grant to Tink Link
      def delegate_grant_auth(tink_user_id:, grant_access_token:, current_user:)
        response = RestClient.post "#{API_ENDPOINT}/oauth/authorization-grant/delegate",
                                   {
                                       user_id: tink_user_id,
                                       id_hint: current_user.email,
                                       actor_client_id: 'df05e4b379934cd09963197cc855bfe9',
                                       scope: 'credentials:read,credentials:refresh,credentials:write,providers:read,user:read,authorization:read'
                                   },
                                   {
                                       'Authorization' => "Bearer #{grant_access_token}"
                                   }

        JSON.parse(response.body).symbolize_keys
      end
    end
  end
end