class UsersController < ApplicationController
  before_action :authenticate_user!, except: [:books, :reviews]

  def books
    user = User.find params[:id]
    books_of_user = user.buyed_books.as_json
    if books_of_user.length == 0
      render status: 200, json: { message: I18n.t('users.success.empty', user_name: user[:user_name]) }
    else
      books_of_user.each do |book|
        book["title"] = Book.select(:title).find(book["book_id"])["title"]
      end
      render status: 200, json: books_of_user.collect{|a| a.slice('id', 'user_id', 'book_id', 'title')}
    end
  rescue ActiveRecord::RecordNotFound => e
    render status: 404, json: { message: e}
  end

  def reviews
    user = User.find(params[:id])
    if user.reviewed_books.empty?
      render status: 400, json: { message: I18n.t('users.error.not_exists') } 
    else
      render status: 200, json: { reviews: user.reviewed_books.select(:id, :book_id, :text) }
    end
  rescue ActiveRecord::RecordNotFound
    render status: 404, json: { message: I18n.t('users.error.exists') }
  end

  def destroy
    user = get_current_user
    if user.role == "admin"
      if User.find(params[:id].split(',')).each do |user| user.destroy end
        render status: 200, json: { message: I18n.t('users.success.destroy') }
      end
    else
      render status: 400, json: { message: I18n.t('users.error.not_admin')}
    end
  rescue ActiveRecord::RecordNotFound
    render status: 404, json: { message: I18n.t('users.error.exists') }
  end
end
