Rails.application.routes.draw do
  default_url_options host: ENV['HOST_URL'] || 'localhost:3000'

  mount RailsAdmin::Engine => '/fjvbeiubs0285htdhsb3384q9hv75q343rubfv74qrgid98034uhfsqrbbq2lmbe7e', as: 'rails_admin'

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
      get 'messages/departments'
      get 'messages/kinds'
      resources :messages

      resources :users, only: :index do
        collection do
          get :email_status
          get :phone_status
          get :details
        end

        member do
          get :verify_otp
          get :accounts
          get :subscription_status
          get :notifications
          patch :update
        end
      end

      resources :accounts, only: :index do
        get :linking_code, on: :collection
        get :renew_credentials_link, on: :member
        put :update_credentials, on: :member
        put :refresh_credentials, on: :member
        resources :transactions, only: [:index, :update]
      end

      resources :transactions, only: :show do
        get :all, on: :collection
        get :types, on: :collection
        post :assign_property, on: :member
        post :assign_expense, on: :member
        delete :assign_expense, on: :member
        patch :assign_expense, on: :member
        put :assign_expense, on: :member
      end

      resources :tink_tokens, only: :create

      resources :properties do
        collection { get :expenses_summary }
        collection { get :collected_summary }
        get :collected_summary, on: :member
        get :expenses_summary, on: :member
        resources :tenants do
          get :archive, on: :member
        end
        get :archive, on: :member
      end

      resources :expenses

      resources :addresses

      resources :subscriptions do
        collection do
          get :initiate_redirect_flow
          get :complete_redirect_flow
        end
      end

      resources :home, only: :index do
        collection do
          get :all_data
          get :collected
          get :details
        end
      end
    end
  end

  get '/callback', to: 'tink_hooks#callback'
end
