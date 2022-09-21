class BuyedBooksController < ApplicationController
  before_action :authenticate_user!

  def create
    user = current_user
    quantity, book_id = buyed_book_params[:quantity], buyed_book_params[:book_id]
    quantity = quantity.to_i
    if quantity <= 0
      render json: { message: I18n.t('buyed_books.error.quantity') }
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
          render status: 200, json: { message: I18n.t('buyed_books.success.create', title: book[:title], total_price: total_price) }
        end
      else
        render status: 400, json: { message: I18n.t('buyed_books.error.create') }
      end
    end
  rescue ActiveRecord::RecordNotFound
    render status: 404, json: { message: I18n.t('buyed_books.error.not_exists') }
  end

  private

  def buyed_book_params
    params.require(:buyed_book).permit(:user_id, :book_id, :quantity)
  end

end
