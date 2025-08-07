Rails.application.routes.draw do
  mount Rswag::Ui::Engine => "/api-docs"
  mount Rswag::Api::Engine => "/api-docs"

  namespace :api do
    namespace :v1 do
      get "health", to: "health#check"

      resources :sleep_records, only: [ :create, :update, :index ]

      post "follow/:followed_id", to: "follows#create"
      delete "unfollow/:followed_id", to: "follows#destroy"
      get "followers", to: "follows#followers"
      get "following", to: "follows#following"

      get "feeds", to: "feeds#index"
    end
  end
end
