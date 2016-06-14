Rails.application.routes.draw do
  root to: "home#index"

  mount_devise_token_auth_for 'User', at: '/api/v0/auth'

  namespace :api do
    namespace :v0 do
      resources :apidocs, only: [:index]

      ######### Home Routes #############
      post '/contact', to: 'home#contact'

      resources :users, only: [:show] do
        collection do
          get '/ecg_stream', to: 'users#ecg_stream'
        end
      end

      resources :ecg_streams, only: [] do
        collection do
          patch '/log_stream', to: 'ecg_streams#log_stream'
        end
      end
    end
  end
end