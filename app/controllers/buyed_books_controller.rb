class BuyedBooksController < ApplicationController

  def availaible_quantity
    user = get_current_user

    purchase_book = BuyedBook.new({
      user_id: user.id,
      book_id: buyed_book_params[:book_id],
      quantity: buyed_book_params[:quantity]
    })
    book = Book.find(purchase_book[:book_id])
    if book[:quantity] >= purchase_book[:quantity]
      book[:quantity] = book[:quantity] - purchase_book[:quantity]
      total_price = book[:price] * purchase_book[:quantity]
      if purchase_book.save! && book.save!
        render status: 200, json: "You have successfully purchased #{book[:title]} by written by #{book[:author]}. Your total price is #{total_price}." 
      else
        render status: 400, json: "Something went wrong!"
      end
    else
      render status: 400, json: "Sorry, we are out of stock!"
    end
  rescue ActiveRecord::RecordNotFound
    render status: 400, json: "Could not find a book with id #{purchase_book[:book_id]}"
  rescue ActiveRecord::RecordNotUnique
    render status: 400, json: "You have already purchased this book" 
  end

  private

  def buyed_book_params
    params.require(:buyed_book).permit(:user_id, :book_id, :quantity)
  end

end
