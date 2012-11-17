AmtrakMessenger::Application.routes.draw do
  root :to => "sessions#new"

  resources :users do
    member do
      post :heartbeat
    end
  end
  resources :messages, :only => [:create, :index, :update]
  resources :recipients, :only => [:create, :index, :destroy]
  resources :attachments, :only => [:create]
  resources :transcripts, :only => [:new, :create, :show, :index]
  resources :workstations, only: [:index]
  resource :session, :only => [:new, :create, :update, :destroy]

  match "/register", :to => "users#new"
  match "/signin", :to => "sessions#new"
  match "/signout", :to => "sessions#destroy"
end

