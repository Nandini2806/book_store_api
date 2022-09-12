class BooksController < ApplicationController
  before_action :authenticate_user!
  skip_before_action :authenticate_user!, only: [:create, :destroy, :update, :show]

  def index
    book_list = Book.all
    render status: 200, json: book_list.select(:id, :title, :genre, :author, :published_year, :price)
  rescue  ActiveRecord::RecordNotFound
    render json: "Sorry, No books availaible at this time!"
  end

  def create
    new_book = Book.new(new_book_params)
    if new_book.save!
      render status: 200, json: 'New Book has been Added!'
    end
  rescue ActiveRecord::RecordInvalid
    render status: 400, json: "#{new_book[:title]} written by #{new_book[:author]} already exits!"
  end

  def show
    book = Book.find(params[:id])
    render json: book.reviewed_books.select(:id, :text)
  rescue  ActiveRecord::RecordNotFound
    render json: "Book with id #{params[:id]} does not exist!"
  end

  def show_books_by_filter
    filter_by = filter_params
    if filter_by[:genre] && filter_by[:author]
      book_list = Book.where(genre: filter_by[:genre], author: filter_by[:author])
    elsif filter_by[:author]
      book_list = Book.where(author: filter_by[:author])
    elsif filter_by[:genre]
      book_list = Book.where(genre: filter_by[:genre])
    end
    render json: (book_list.empty?) ? "There are no books availaible with this filter": book_list.select(:id, :title, :author, :genre)
  end

  def destroy
    del_book = delete_book_params
    book = Book.find_by(title: del_book[:title])
    if Book.destroy(book[:id])
      render status: 200, json: 'Book successfully Deleted!'
    end
  rescue NoMethodError
    render status: 400, json: "Book must exist!"
  end

  def update
    book = Book.find(update_book_params[:id])
    if book.update(quantity: (book[:quantity] + update_book_params[:quantity]))
      render json: "Quantity updated!" 
    end
  rescue ActiveRecord::RecordNotFound
    render json: "Could not update quantity because this book does not exist!"
  end

  private

  def new_book_params
    params.require(:book).permit(:title, :genre, :author, :published_year, :price, :quantity)
  end

  def filter_params
    params.require(:filter).permit(:genre, :author)
  end

  def delete_book_params
    params.require(:book).permit(:id, :title)
  end

  def update_book_params
    params.require(:book).permit(:id, :title, :author, :quantity)
  end

end
