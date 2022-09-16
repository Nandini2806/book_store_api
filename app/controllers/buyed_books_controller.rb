class BuyedBooksController < ApplicationController
  before_action :authenticate_user!

  def create
    user = get_current_user
    quantity, book_id = buyed_book_params[:quantity], buyed_book_params[:book_id]
    if quantity <= 0
      render json: { message: "Please enter valid quantity" }
    else
      if BuyedBook.exists?(:user_id => user.id) && BuyedBook.exists?(:book_id => book_id)
        purchase_book = BuyedBook.find_by(user_id: user.id, book_id: book_id)
      else 
        purchase_book = BuyedBook.new({
          user_id: user.id,
          book_id: book_id,
          quantity: 0
        })
      end
      book = Book.find(purchase_book[:book_id])
      quantity = quantity.to_i
      if book[:quantity] >= quantity
        book[:quantity] -= quantity
        purchase_book[:quantity] += quantity
        total_price = book[:price] * quantity
        if purchase_book.save! && book.save!
          render status: 200, json: { message: "You have successfully purchased #{book[:title]} by written by #{book[:author]}. Your total price is #{total_price}." }
        end
      else
        render status: 400, json: { message: "Sorry, we are out of stock!" }
      end
    end
  rescue ActiveRecord::RecordNotFound
    render status: 404, json: { message: "Could not find book!" }
  end

  private

  def buyed_book_params
    params.require(:buyed_book).permit(:user_id, :book_id, :quantity)
  end

end
