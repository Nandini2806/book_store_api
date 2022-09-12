Rails.application.routes.draw do
  mount_devise_token_auth_for 'User', at: 'auth'
  # For details on the DSL available within this file, see https://guides.rubyonrails.org/routing.html

  resources :buyed_books, only: :create

  resources :reviews, only: :create
  
  resources :books, only: [:create, :destroy, :index, :update] do 
    get :reviews, on: :member
  end

  resources :users, include: [:show, :destroy] do
    get :books, on: :member
    get :reviews, on: :member
  end

end