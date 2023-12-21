Rails.application.routes.draw do
  # Define your application routes per the DSL in https://guides.rubyonrails.org/routing.html

  # Reveal health status on /up that returns 200 if the app boots with no exceptions, otherwise 500.
  # Can be used by load balancers and uptime monitors to verify that the app is live.
  get "up" => "rails/health#show", as: :rails_health_check

  # Defines the root path route ("/")
  root 'application#index'

  namespace :api, constraints: { format: 'json' } do
    namespace :v1 do
      post '/login', to: 'sessions#login'
      post '/signup', to: 'registrations#signup'
      delete '/logout', to: 'sessions#logout'
      get '/logined-user', to: 'sessions#logined_user'
      post '/refresh-token', to: 'sessions#refresh_token'
    end
  end
end
