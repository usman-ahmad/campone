Rails.application.routes.draw do
  mount Ckeditor::Engine => '/ckeditor'
  mount API::Root => '/'

  resources :projects do
    resources :tasks do
      patch :assigned_to_me,:start_progress, on: :member
      resources :comments
    end

    resources :discussions do
      resources :comments
    end

    resources :contributions, only: [:new, :create]
    resources :attachments, only: [:index, :new, :create, :destroy,:edit,:update] do
      member do
        get 'download'
      end
    end

    resources :events do
      get :get_events, on: :collection
    end
  end

  devise_for :users
  # The priority is based upon order of creation: first created -> highest priority.
  # See how all your routes lay out with "rake routes".

  # You can have the root of your site routed with "root"
  resource :notifications do
    member do
      get 'index'
      patch 'update'
    end
  end
  root 'welcome#index'
  get 'notifications' => 'notifications#index'

  # Example of regular route:
  #   get 'products/:id' => 'catalog#view'

  # Example of named route that can be invoked with purchase_url(id: product.id)
  #   get 'products/:id/purchase' => 'catalog#purchase', as: :purchase

  # Example resource route (maps HTTP verbs to controller actions automatically):
  #   resources :products

  # Example resource route with options:
  #   resources :products do
  #     member do
  #       get 'short'
  #       post 'toggle'
  #     end
  #
  #     collection do
  #       get 'sold'
  #     end
  #   end

  # Example resource route with sub-resources:
  #   resources :products do
  #     resources :comments, :sales
  #     resource :seller
  #   end

  # Example resource route with more complex sub-resources:
  #   resources :products do
  #     resources :comments
  #     resources :sales do
  #       get 'recent', on: :collection
  #     end
  #   end

  # Example resource route with concerns:
  #   concern :toggleable do
  #     post 'toggle'
  #   end
  #   resources :posts, concerns: :toggleable
  #   resources :photos, concerns: :toggleable

  # Example resource route within a namespace:
  #   namespace :admin do
  #     # Directs /admin/products/* to Admin::ProductsController
  #     # (app/controllers/admin/products_controller.rb)
  #     resources :products
  #   end
end
