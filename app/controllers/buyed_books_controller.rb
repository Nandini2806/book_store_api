class BuyedBooksController < ApplicationController

  def create
    user = get_current_user
    crnt_purchase = buyed_book_params
    if BuyedBook.find_by(user_id: user.id).present? && BuyedBook.find_by(book_id: crnt_purchase[:book_id]).present?
      purchase_book = BuyedBook.find_by(user_id: user.id, book_id: crnt_purchase[:book_id])
    else 
      purchase_book = BuyedBook.new({
        user_id: user.id,
        book_id: crnt_purchase[:book_id],
        quantity: 0
      })
    end
    book = Book.find(purchase_book[:book_id])
    crnt_purchase[:quantity] = crnt_purchase[:quantity].to_i
    if book[:quantity] >= crnt_purchase[:quantity]
      book[:quantity] -= crnt_purchase[:quantity]
      total_price = book[:price] * crnt_purchase[:quantity]
      purchase_book[:quantity] += crnt_purchase[:quantity]
      if purchase_book.save! && book.save!
        render status: 200, json: { message: "You have successfully purchased #{book[:title]} by written by #{book[:author]}. Your total price is #{total_price}." }
      end
    else
      render status: 400, json: { message: "Sorry, we are out of stock!" }
    end
  rescue ActiveRecord::RecordNotFound
    render status: 404, json: { message: "Could not find a book with id #{purchase_book[:book_id]}" }
  end

  private

  def buyed_book_params
    params.require(:buyed_book).permit(:user_id, :book_id, :quantity)
  end

end
