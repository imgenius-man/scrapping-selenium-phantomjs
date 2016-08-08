Academia::Application.routes.draw do

  devise_for :users

  resources :statuses

  resources :service_types do
    member do
      get 'index'
    end
  end
 
  resources :dashboard do 
    collection do
      get :eligibility
    end
  end
 
  root :to => 'dashboard#index'

  get 'eligibility', :to => 'dashboard#eligibility'
  
  resources :patients do
  	collection do
      post 'apis_eligibility'
  		post 'search_data'
      post 'sign_in_api'
      post 'access_token'
      post 'verify_credentials'
      post 'import'
      post 'import_mapping'
      post 'authenticate_token'
      get 'transaction_logs'
      get 'delete_all'
  	end
  end
end
