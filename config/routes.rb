TrackingETFs::Application.routes.draw do
  # The priority is based upon order of creation:
  # first created -> highest priority.
  resources :funds
  resources :sessions,      :only => [:new, :create, :destroy]
  
  # Sample of regular route:
  #match '/home' => 'main_page#home', :as => :home  
  match '/' => 'pages#home'
  match 'etf/:id' => 'funds#show'
  match 'etf/:tickersymbol' => 'funds#ticker'
  match 'search/' => 'funds#find'
  match 'about/' => 'funds#about'
  match 'dailyprices' => 'dailyprices#index'
  match 'top50ytd/' => 'funds#top50ytd'
  match 'top25month/' => 'funds#top25month'
  match 'weeksbiggestmovers/' => 'funds#weeksbiggestmovers'
  match 'login', :controller => 'sessions', :action => 'new'
  match 'logout', :controller => 'sessions', :action => 'destroy'
  match 'login/success', :controller => 'sessions', :action => 'loginsuccess'
  match 'login/failure', :controller => 'sessions', :action => 'loginfailure'
  match 'category/:name', :controller => 'funds', :action => 'category'
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

  # See how all your routes lay out with "rake routes"

  # This is a legacy wild controller route that's not recommended for RESTful applications.
  # Note: This route will make all actions in every controller accessible via GET requests.
  # match ':controller(/:action(/:id(.:format)))'
end
