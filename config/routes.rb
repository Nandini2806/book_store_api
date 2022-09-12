Rails.application.routes.draw do
  mount_devise_token_auth_for 'User', at: 'auth'
  # For details on the DSL available within this file, see https://guides.rubyonrails.org/routing.html

  get '/books_purchased', to: 'users#show'
  get '/all_reviews', to: 'users#show_all_reviews'
  delete '/delete_user', to: 'users#destroy'

  get '/all_books', to: 'books#index'
  get '/reviews/:id', to: 'books#show'
  post '/new_book', to: 'books#create'
  post '/book_by_filter', to: 'books#show_books_by_filter'
  put '/add_books', to: 'books#update'
  delete '/delete_book', to: 'books#destroy'
  
  post '/new_review', to: 'reviews#create'

  post '/buy_book', to: 'buyed_books#availaible_quantity'
  
end