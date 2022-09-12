class UsersController < ApplicationController
  before_action :authenticate_user!
  skip_before_action :authenticate_user!, only: [:destroy]

  def show
    user = get_current_user
    purchase_books_id = BuyedBook.where(user_id: user.id)
    book_list = []
    purchase_books_id.each do |book|
      b = Book.find(book[:book_id])
      book_list.append({ book_id: b[:id], title: b[:title], author: b[:author] })
    end
    render status: 200, json: book_list
  end

  def show_all_reviews
    user = get_current_user
    if user.reviewed_books.empty?
      render status: 400, json: "You haven't added any reviews yet"
    else
      render status: 200, json: user.reviewed_books.select(:id, :book_id, :text)
    end
  end

  def destroy
    del_user = delete_user_params
    if User.destroy(User.find_by(del_user)[:id])
      render status: 200, json: 'User successfully Deleted!'
    end
  rescue NoMethodError
    render status: 400, json: "User must exist!"
  end

  private

  def delete_user_params
    params.require(:user).permit(:user_name)
  end
end
