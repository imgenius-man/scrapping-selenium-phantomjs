Academia::Application.routes.draw do

  # devise_for :admin_users, ActiveAdmin::Devise.config
  # ActiveAdmin.routes(self)
# devise_for :users, path_names: {sign_in: "login", sign_out: "logout"}
    # devise_for :users
    root :to => 'dashboard#index'
    resources :users do
    	collection do
    		post 'search_data'
    	end
    end
    # root :to => '/users/sign_in'
    
end