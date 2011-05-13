Spotcandy::Application.routes.draw do
  resources :photos

  devise_for :admin

  resources :candies, :except => [:show]

  resources :venues, :except => [:show]
  

  #devise_for :users

  devise_for :users, :controllers => {:registrations => 'registrations', :sessions => 'sessions'}
  
  resources :users
  resources :admin, :only => [:index]
  
  get "candies/cleanup"
  get "candies/privileges"
  
  match 'auth/:provider' => 'authentications#index', :constraints => {:provider => /foursquare|facebook/}
  #match 'auth/:provider' => 'authentications#index', :constraints => {:provider => /foursquare/}
  match 'auth/:provider/callback', :to => 'authentications#callback'
  match 'search_candies' => "venues#search"
  match 'venue/:id/candies' => "venues#candies"
  match 'venue/people' => "venues#people"
  match 'venue/:id/add' => "venues#add"
  match 'venue/:id/watch' => "venues#watch"
  match 'venues/trending' => "venues#trending"
  match 'venues/popular' => "venues#popular"
  match 'venues/history' => "venues#history"
  match 'venues/random' => "venues#random"
  match 'candy/:id/add' => "users#add_candy"
  match 'candy/:id/remove' => "users#remove_candy"
  match 'candy/:id/flag' => "candies#flag"
  match 'candy/:id/update_profile' => "candies#update_profile"
  match 'candy/:id/photos' => "candies#detail"
  match 'candy/:id/display' => "candies#display"
  match 'candy/:pid/profile' => "candies#profile"
  match 'candies/cleanup' => "candies#cleanup"
  match 'candies/:id' => "candies#show"
  match 'candies-grid' => "candies#grid"
  match 'user/:id/candies' => "users#candies"
  match 'scout/:id/candies' => "users#candies_list"
  match 'leaderboard' => "pages#home"
  match 'faq' => "pages#faq"
  match 'spotted' => "pages#stream"
  match 'pages/test' => "pages#test"
  match 'gallery' => "pages#candies"
  match 'contest' => "pages#contest"
  #match 'cron' => "users#cron"
  
  
  devise_scope :admin do
    get "admin/login", :to => "devise/sessions#new"
  end
  
  scope "/admin" do
    resources :venues
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
  root :to => "pages#home"

  # See how all your routes lay out with "rake routes"

  # This is a legacy wild controller route that's not recommended for RESTful applications.
  # Note: This route will make all actions in every controller accessible via GET requests.
  # match ':controller(/:action(/:id(.:format)))'
end
