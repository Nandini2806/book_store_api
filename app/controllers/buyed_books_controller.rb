class BuyedBooksController < ApplicationController

  def availaible_quantity
    purchase_book = BuyedBook.new(buyed_book_params)
    if User.exists?(purchase_book[:user_id])
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
        render status: 400, json: "Book not availaible!"
      end
    else
      render json: 'User does not exist'
    end
  rescue ActiveRecord::RecordNotUnique
    render json: "You have already purchased this book" 
  end

  private

  def buyed_book_params
    params.require(:buyed_book).permit(:user_id, :book_id, :quantity)
  end

end
