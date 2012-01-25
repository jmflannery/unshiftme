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
#== Route Map
# Generated on 24 Jan 2012 23:55
#
#       users GET    /users(.:format)          users#index
#             POST   /users(.:format)          users#create
#    new_user GET    /users/new(.:format)      users#new
#   edit_user GET    /users/:id/edit(.:format) users#edit
#        user GET    /users/:id(.:format)      users#show
#             PUT    /users/:id(.:format)      users#update
#    messages GET    /messages(.:format)       messages#index
#             POST   /messages(.:format)       messages#create
#  recipients GET    /recipients(.:format)     recipients#index
#             POST   /recipients(.:format)     recipients#create
#   recipient DELETE /recipients/:id(.:format) recipients#destroy
#     session POST   /session(.:format)        sessions#create
# new_session GET    /session/new(.:format)    sessions#new
#             DELETE /session(.:format)        sessions#destroy
#      signup        /signup(.:format)         users#new
#      signin        /signin(.:format)         sessions#new
#     signout        /signout(.:format)        sessions#destroy
