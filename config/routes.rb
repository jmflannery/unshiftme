Unshiftme::Application.routes.draw do
  root :to => "sessions#new"

  resources :users do
    resources :messages, :only => [:create, :index, :update]
    resources :attachments, :only => [:create, :index]
    resources :transcripts, :only => [:new, :create, :show, :index, :destroy]
    member do
      get :edit_password
      put :update_password
      put :heartbeat
      put :promote
    end
  end
  resources :message_routes, :only => [:create, :index, :destroy]
  resources :workstations, only: [:index]
  resource :session, :only => [:new, :create, :update, :destroy]

  match "/register", :to => "users#new"
  match "/signin", :to => "sessions#new"
  match "/signout", :to => "sessions#destroy"
end

