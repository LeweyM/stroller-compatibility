Rails.application.routes.draw do
  get 'products/index'
  get 'products/show'
  get 'products/search', to: 'products#search'
  get 'products/search_comparison', to: 'products#search_comparison'
  resources :products, param: :slug, path: '' do
    member do
      get :fits
      get 'fits/:b_id', to: 'products#compatible', param: :slug
    end
  end
  resources :brands
  # Define your application routes per the DSL in https://guides.rubyonrails.org/routing.html

  # Reveal health status on /up that returns 200 if the app boots with no exceptions, otherwise 500.
  # Can be used by load balancers and uptime monitors to verify that the app is live.
  get "up" => "rails/health#show", as: :rails_health_check

  # Defines the root path route ("/")
  root "brands#index"
end