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
    render status: 200, json: (book_list.empty?) ? { message: I18n.t('books.success.no_books') } : { books: book_list.as_json(only: [:id, :title, :author, :genre, :quantity]) }
  end

  def create
    user = get_current_user
    if user.role == "admin"
      new_book = Book.new(new_book_params)
      if new_book.save!
        render status: 200, json: { message: I18n.t('books.success.create') }
      end
    else
      render status: 400, json: { message: I18n.t('books.error.not_admin')}
    end
  rescue ActiveRecord::RecordInvalid
    render status: 400, json: { message: I18n.t('books.error.exists', new_book_title: new_book[:title], new_book_author: new_book[:author]) }
  end

  def reviews
    book = Book.find(params[:id])
    render status: 200, json: { reviews: book.reviewed_books.select(:id, :text) }
  rescue  ActiveRecord::RecordNotFound
    render status: 404, json: { message: I18n.t('books.error.not_exists', id: params[:id]) }
  end

  def destroy
    user = get_current_user
    if user.role == "admin"
      if Book.find(params[:id].split(',')).each do |book| book.destroy end
        render status: 200, json: { message: I18n.t('books.success.destroy') }
      end
    else
      render status: 400, json: { message: I18n.t('books.error.not_admin') }
    end
  rescue ActiveRecord::RecordNotFound
    render status: 404, json: { message: I18n.t('books.error.not_exists') }
  end

  def update
    user = get_current_user
    if user.role == "admin"
      if update_book_params[:quantity].to_i <= 0
        render status: 400, json: { message: I18n.t('books.error.update') }
      else
        book = Book.find(params[:id])
        if book.update(quantity: (book[:quantity] + update_book_params[:quantity].to_i))
          render status: 200, json: { message: I18n.t('books.success.update', quantity: book[:quantity]) }
        end
      end
    else
      render status: 400, json: { message: I18n.t('books.error.not_admin') }
    end
  rescue ActiveRecord::RecordNotFound
    render status: 404, json: { message: I18n.t('books.error.not_exists') }
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
