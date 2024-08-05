Rails.application.routes.draw do
  get 'products/index'
  get 'products/search', to: 'products#search'
  get 'products/search_comparison', to: 'products#search_comparison'
  resources :products, param: :slug, path: '', :only => ['index', 'fits', 'comparison'] do
    member do
      get :fits
      get 'fits/:b_id', to: 'products#compatible', param: :slug, as: :compatible
    end
  end
  resources :brands, only: [:index]
  namespace :admin do
    get 'images/new'
    get 'images/create'
    get 'images/destroy'
    resources :products, path: '', only: [:index, :new, :edit, :destroy, :update] do
      resources :images, only: [:new, :create, :destroy]
      collection do
        post :import
      end
    end
  end
  # Define your application routes per the DSL in https://guides.rubyonrails.org/routing.html

  # Reveal health status on /up that returns 200 if the app boots with no exceptions, otherwise 500.
  # Can be used by load balancers and uptime monitors to verify that the app is live.
  get "up" => "rails/health#show", as: :rails_health_check

  # Defines the root path route ("/")
  root "brands#index"
end