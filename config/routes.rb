Academia::Application.routes.draw do

  resources :statuses
  resources :service_types


  # devise_for :admin_users, ActiveAdmin::Devise.config
  # ActiveAdmin.routes(self)
# devise_for :users, path_names: {sign_in: "login", sign_out: "logout"}
    # devise_for :users
    root :to => 'dashboard#index'
    resources :users do
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
    # root :to => '/users/sign_in'

end
