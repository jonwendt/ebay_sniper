EbaySniper::Application.routes.draw do

  devise_for :users, :controllers => { :registrations => "users", :sessions => "sessions" }
  
  resources :search do
    member do
      post :new
    end
  end
  
  resources :auctions do
    collection do
      post :remove_multiple
      post :restore_multiple
      post :create_multiple
      get :import
    end
    member do
      post :restore
      get :update_info
    end
  end

  resources :users
  resources :home
  resources :notifications
  
  get "call_handler", :to => "notifications#receive"
  
  devise_scope :user do
    get "user_root", :to => "users#check_token"
    get "user/add_token", :to => "users#add_token"
    get "user/check_token", :to => "users#check_token"
    get "user/consent_failed", :to => "users#consent_failed"
  end

  # The priority is based upon order of creation:
  # first created -> highest priority.

  # Sample of regular route:
  #   match 'products/:id' => 'catalog#view'
  # Keep in mind you can assign values other than :controller and :action

  # Sample of named route:
  #   match 'products/:id/purchase' => 'catalog#purchase', :as => :purchase
  # This route can be invoked with purchase_url(:id => product.id)

  # Sample resource route (maps HTTP verbs to controller actions automatically):
  #   resources :products

  # Sample resource route with options:
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

  # Sample resource route with sub-resources:
  #   resources :products do
  #     resources :comments, :sales
  #     resource :seller
  #   end

  # Sample resource route with more complex sub-resources
  #   resources :products do
  #     resources :comments
  #     resources :sales do
  #       get 'recent', :on => :collection
  #     end
  #   end

  # Sample resource route within a namespace:
  #   namespace :admin do
  #     # Directs /admin/products/* to Admin::ProductsController
  #     # (app/controllers/admin/products_controller.rb)
  #     resources :products
  #   end

  # You can have the root of your site routed with "root"
  # just remember to delete public/index.html.
  # root :to => 'welcome#index'

  root :to => "home#index"

  #match "user_root", :to => "users#check_token"
  
  # See how all your routes lay out with "rake routes"

  # This is a legacy wild controller route that's not recommended for RESTful applications.
  # Note: This route will make all actions in every controller accessible via GET requests.
  # match ':controller(/:action(/:id))(.:format)'
end
