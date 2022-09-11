class UsersController < ApplicationController

  def show
    user = User.find_by(user_name_params)[:id]
    purchase_books_id = BuyedBook.where(user_id: user)
    book_list = []
    purchase_books_id.each do |book|
      b = Book.find(book[:book_id])
      book_list.append({ book_id: b[:id], title: b[:title] })
    end
    render json: book_list
  end

  def destroy
    del_user = delete_user_params
    if User.destroy(User.find_by(del_user)[:id])
      render status: 200, json: 'User successfully Deleted!'
    else
      render status: 400, json: 'Could not delete user!'
    end
  end

  private
  
  def user_name_params
    params.require(:user).permit(:user_name)
  end

  def delete_user_params
    params.require(:user).permit(:user_name)
  end
end
