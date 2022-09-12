class BooksController < ApplicationController
  before_action :authenticate_user!

  def index
    filter_by = filter_params

    if filter_by[:genre] && filter_by[:author]
      book_list = Book.where(genre: filter_by[:genre], author: filter_by[:author])
    elsif filter_by[:author]
      book_list = Book.where(author: filter_by[:author])
    elsif filter_by[:genre]
      book_list = Book.where(genre: filter_by[:genre])
    else
      book_list = Book.all
    end
    render json: (book_list.empty?) ? { message: "There are no books availaible with this filter" } : { message: book_list.select(:id, :title, :author, :genre) }
  rescue  ActiveRecord::RecordNotFound
    render status: 400, json: { message: "Sorry, No books availaible at this time!" }
  end

  def create
    user = get_current_user
    if user.role == "admin"
      new_book = Book.new(new_book_params)
      if new_book.save!
        render status: 200, json: { message: 'New Book has been Added!' }
      end
    else
      render status: 400, json: { message: "Cannot add book. You are not an admin"}
    end
  rescue ActiveRecord::RecordInvalid
    render status: 400, json: { message: "#{new_book[:title]} written by #{new_book[:author]} already exits!" }
  end

  def reviews
    book = Book.find(params[:id])
    render json: book.reviewed_books.select(:id, :text)
  rescue  ActiveRecord::RecordNotFound
    render json: { message: "Book with id #{params[:id]} does not exist!" }
  end

  def destroy
    user = get_current_user
    if user.role == "admin"
      if Book.find(params[:id].split(',')).each do |book| book.destroy end
        render status: 200, json: { message: 'Book(s) successfully Deleted!' }
      end
    else
      render status: 400, json: { message: "Cannot delete book. You are not an admin"}
    end
  rescue ActiveRecord::RecordNotFound
    render status: 400, json: { message: "Book(s) must exist!" }
  end

  def update
    user = get_current_user
    if user.role == "admin"
      book = Book.find(params[:id])
      if book.update(quantity: (book[:quantity] + update_book_params[:quantity]))
        render json: { message: "Quantity updated!" }
      end
    else
      render status: 400, json: { message: "Cannot add quantity to book. You are not an admin" }
    end
  rescue ActiveRecord::RecordNotFound
    render json: { message: "Could not update quantity because this book does not exist!" }
  end

  private

  def new_book_params
    params.require(:book).permit(:title, :genre, :author, :published_year, :price, :quantity)
  end

  def filter_params
    params.permit(:genre, :author)
  end

  def update_book_params
    params.require(:book).permit(:quantity)
  end

end
