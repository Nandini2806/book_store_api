class UsersController < ApplicationController
  before_action :authenticate_user!, except: [:books]

  def books
    purchase_books_id = BuyedBook.where(user_id: params[:id])
    if purchase_books_id == []
      render status: 400, json: {message: "User does not exist"}
    else
      book_list = []
      purchase_books_id.each do |book|
        b = Book.find(book[:book_id])
        book_list.append({ book_id: b[:id], title: b[:title], author: b[:author], price: b[:price] })
      end
      render status: 200, json: { books_purchased: book_list }
    end
  end

  def reviews
    user = get_current_user
    if user.reviewed_books.empty?
      render status: 400, json: { message: "You haven't added any reviews yet" } 
    else
      render status: 200, json: { reviews: "#{user.reviewed_books.select(:id, :book_id, :text)}" }
    end
  end

  def destroy
    user = get_current_user
    if user.role == "admin"
      if User.find(params[:id].split(',')).each do |user| user.destroy end
        render status: 200, json: { message: 'User(s) successfully Deleted!' }
      end
    else
      render status: 400, json: { message: "Invalid action! You are not an admin."}
    end
  rescue ActiveRecord::RecordNotFound
    render status: 404, json: { message: "User(s) must exist!" }
  end
end
