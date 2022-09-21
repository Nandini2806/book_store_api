class ReviewsController < ApplicationController
  before_action :authenticate_user!

  def create
    user = current_user
      if Book.exists? reviewed_book_params[:book_id]
        if reviewed_book_params[:text]
          review = ReviewedBook.new({user_id: user.id,
            book_id: reviewed_book_params[:book_id],
            text: reviewed_book_params[:text]
          })
          if review.save!
            render status: 200, json: { message: I18n.t('reviews.success.create', user_id: user[:id], book_id: review[:book_id])}
          end
        else
          render status: 400, json: { message: I18n.t('reviews.error.text')}
        end
      else
        render status: 404, json: { message: I18n.t('reviews.error.create') }
      end
    rescue ActiveRecord::RecordInvalid
      render status: 400, json: { message: I18n.t('reviews.error.exists') }
    end

  private

  def reviewed_book_params
    params.require(:review).permit(:book_id, :text)
  end
end
