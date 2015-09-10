Wishlist::Application.routes.draw do
  root 'static_pages#home'

  match '/signin', to: 'sessions#new', via: :get, as: :signin
  match '/signup', to: 'users#new', via: :get, as: :signup
  match '/signout', to: 'sessions#destroy', via: 'delete', as: :signout

  resources :users, only: [:new, :create, :show]
  resources :sessions, only: [:new, :create, :destroy]
end
