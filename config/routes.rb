Rails.application.routes.draw do
  mount_devise_token_auth_for 'User', at: 'api/v1/auth',  controllers: {
      registrations: 'overrides/registrations',
      sessions: 'overrides/sessions',
  }
  # For details on the DSL available within this file, see https://guides.rubyonrails.org/routing.html

  namespace :api do
    namespace :v1 do
      resources :users, only: :index do
        get :verify_otp, on: :member
        get :accounts, on: :member
        get :email_status, on: :collection
        get :phone_status, on: :collection
        get :details, on: :collection
      end

      resources :accounts, only: :index

      resources :tink_tokens, only: :create
    end
  end

  get '/callback', to: 'tink_hooks#callback'
end
