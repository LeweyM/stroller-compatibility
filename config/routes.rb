Rails.application.routes.draw do
  get 'products/index'
  get 'products/search', to: 'products#search'
  resources :products, param: :slug, path: '', :only => ['index', 'fits', 'comparison'] do
    member do
      get :fits
      get 'fits/:b_id', to: 'products#compatible', param: :slug, as: :compatible
    end
  end
  resources :brands, only: [:index]
  namespace :admin do
    get '', to: redirect('admin/products')
    resources :compatibility, only: [:index] do
      collection do
        delete :unlink
        post :link
      end
    end
    resources :brands, path: 'brands', only: [:index, :new, :edit, :destroy, :update] do
      collection do
        get :export
      end
    end
    resources :products, path: 'products', only: [:index, :new, :edit, :destroy, :update] do
      delete :destroy_image, on: :member, controller: :images
      resources :images, only: [:new, :create] do
        collection do
          post :generate
        end
      end
      collection do
        post :check_url
        post :import
        get :export
        get :export_compatible
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