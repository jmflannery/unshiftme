ChattyPants::Application.routes.draw do
  root :to => "sessions#new"

  resources :users, :only => [:new, :create, :show, :index, :edit, :update] 
  resources :messages, :only => [:create, :index]
  resources :recipients, :only => [:create, :index, :destroy]
  resource :session, :only => [:new, :create, :destroy]

  match "/signup", :to => "users#new"
  match "/signin", :to => "sessions#new"
  match "/signout", :to => "sessions#destroy"
end
