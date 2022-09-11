Rails.application.routes.draw do
  mount_devise_token_auth_for 'User', at: 'auth'
  # For details on the DSL available within this file, see https://guides.rubyonrails.org/routing.html

  get '/bookspurchased', to: 'users#show'
  delete '/deleteuser', to: 'users#destroy'

  get '/allbooks', to: 'books#index'
  post '/newbook', to: 'books#create'
  post '/bookbyfilter', to: 'books#show_books_by_filter'
  put '/addbooks', to: 'books#update'
  delete '/deletebook', to: 'books#destroy'
  
  post '/newreview', to: 'reviews#create'

  post '/buyedbook', to: 'buyed_books#availaible_quantity'
  
end