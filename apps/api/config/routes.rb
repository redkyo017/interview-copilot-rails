require "sidekiq/web"

Rails.application.routes.draw do
  # Mount Sidekiq web UI in development
  mount Sidekiq::Web => "/sidekiq" if Rails.env.development?

  # Define your application routes per the DSL in https://guides.rubyonrails.org/routing.html

  # Reveal health status on /up that returns 200 if the app boots with no exceptions, otherwise 500.
  # Can be used by load balancers and uptime monitors to verify that the app is live.
  get "up" => "rails/health#show", as: :rails_health_check

  # Defines the root path route ("/")
  # root "posts#index"
  namespace :api do
    resources :ingests, only: [:create, :show]
    resources :queries, only: [:create]
    resources :documents, only: [:index]
  end
  get "/health", to: proc { [200, {"Content-Type"=>"application/json"}, [{ok: true}.to_json]] }

end
