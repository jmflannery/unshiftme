Intercom::Application.routes.draw do
  resources :users, :only => [:new, :create, :show, :edit, :update]
  resources :sessions, :only => [:new, :create, :destroy]
  resources :messages, :only => [:create, :index]

  match "/about", :to => "pages#about"
  match "/features", :to => "pages#features"
  match "/technology", :to => "pages#technology"

  match "/signup", :to => "users#new"
  match "/signin", :to => "sessions#new"
  match "/signout", :to => "sessions#destroy"

  root :to => "pages#about"
end
