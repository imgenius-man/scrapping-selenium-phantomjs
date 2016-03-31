Academia::Application.routes.draw do

  resources :statuses

  resources :service_types do
    member do
      get 'index'
    end
  end

  root :to => 'dashboard#index'
  resources :patients do
  	collection do
  		post 'search_data'
      post 'sign_in_api'
      post 'access_token'
      post 'verify_credentials'
      post 'import'
      post 'import_mapping'
      post 'authenticate_token'
      get 'delete_all'
  	end
  end
end
