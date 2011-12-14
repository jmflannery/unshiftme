Intercom::Application.routes.draw do
  resources :users, :only => [:new, :create, :show, :index, :edit, :update] 
  resources :messages, :only => [:create, :index]
  resource :session, :only => [:new, :create, :destroy] 

  match "/about", :to => "pages#about"
  match "/features", :to => "pages#features"
  match "/technology", :to => "pages#technology"

  match "/signup", :to => "users#new"
  match "/signin", :to => "sessions#new"
  match "/signout", :to => "sessions#destroy"

  root :to => "pages#about"
end
