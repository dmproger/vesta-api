Rails.application.routes.draw do
  mount_devise_token_auth_for 'User', at: 'api/v1/auth',  controllers: {
      registrations: 'overrides/registrations',
      sessions: 'overrides/sessions',
  }
  # For details on the DSL available within this file, see https://guides.rubyonrails.org/routing.html

  namespace :api do
    namespace :v1 do
      resources :users, only: [:index] do
        get :verify_otp, on: :member
      end
    end
  end
end
