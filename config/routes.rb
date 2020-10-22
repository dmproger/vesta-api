Rails.application.routes.draw do
  default_url_options host: ENV['HOST_URL'] || 'localhost:3000'

  resources :properties
  mount_devise_token_auth_for 'User', at: 'api/v1/auth',  controllers: {
      registrations: 'overrides/registrations',
      sessions: 'overrides/sessions',
  }
  # For details on the DSL available within this file, see https://guides.rubyonrails.org/routing.html

  namespace :webhooks do
    resources :gc_webhooks, only: :create
  end

  namespace :api do
    namespace :v1 do
      resources :users, only: :index do
        get :verify_otp, on: :member
        get :accounts, on: :member
        get :email_status, on: :collection
        get :phone_status, on: :collection
        get :details, on: :collection
      end

      resources :accounts, only: :index do
        get :linking_code, on: :collection
        resources :transactions, only: [:index, :update]
      end

      resources :transactions, only: :show do
        get :categories
        post :assign_property, on: :member
      end

      resources :tink_tokens, only: :create

      resources :properties do
        resources :tenants
        get :archive, on: :member
      end

      resources :addresses

      resources :subscriptions do
        collection do
          get :initiate_redirect_flow
          get :complete_redirect_flow
        end
      end
    end
  end

  get '/callback', to: 'tink_hooks#callback'
end
