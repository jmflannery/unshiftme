AmtrakMessenger::Application.routes.draw do
  root :to => "sessions#new"

  resources :users do
    member do
      get :edit_password
      put :update_password
      put :heartbeat
      put :promote
    end
  end
  resources :messages, :only => [:create, :index, :update]
  resources :message_routes, :only => [:create, :index, :destroy]
  resources :attachments, :only => [:create]
  resources :transcripts, :only => [:new, :create, :show, :index, :destroy]
  resources :workstations, only: [:index]
  resource :session, :only => [:new, :create, :update, :destroy]

  match "/register", :to => "users#new"
  match "/signin", :to => "sessions#new"
  match "/signout", :to => "sessions#destroy"
end

