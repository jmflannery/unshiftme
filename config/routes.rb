Unshiftme::Application.routes.draw do
  root :to => "sessions#new"

  resources :users do
    resources :messages, :only => [:create, :index, :update]
    resources :attachments, :only => [:create, :index]
    resources :transcripts, :only => [:new, :create, :show, :index, :destroy]
    member do
      get :edit_password
      patch :update_password
      patch :heartbeat
      patch :promote
    end
  end
  resources :message_routes, :only => [:create, :index, :destroy]
  resources :workstations, only: [:index]
  resource :session, :only => [:new, :create, :update, :destroy]

  get "/register", :to => "users#new"
  get "/signin", :to => "sessions#new"
  get "/signout", :to => "sessions#destroy"
end

