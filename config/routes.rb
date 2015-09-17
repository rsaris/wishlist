Wishlist::Application.routes.draw do
  root 'static_pages#home'

  match '/signin', to: 'sessions#new', via: :get, as: :signin
  match '/signup', to: 'users#new', via: :get, as: :signup
  match '/signout', to: 'sessions#destroy', via: 'delete', as: :signout

  match '/users/search', to: 'users#search', via: 'get', as: :user_search
  match '/users/add_friend', to: 'users#add_friend', via: 'post', as: :add_friend

  resources :users, only: [:new, :create, :show, :index]
  resources :sessions, only: [:new, :create, :destroy]
end
