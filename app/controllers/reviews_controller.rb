class ReviewsController < ApplicationController
  before_action :authenticate_user!

  def create
    user = get_current_user
    review = ReviewedBook.new({
      user_id: user.id,
      book_id: reviewed_book_params[:book_id],
      text: reviewed_book_params[:text]
    })
    if review.save!
      render status: 200, json: "Review for user #{user[:id]} and book #{review[:book_id]} is successfully added!"
    end
  rescue ActiveRecord::RecordInvalid
    render status 400, json: "You have already added review"
  end

  private

  def reviewed_book_params
    params.require(:review).permit(:book_id, :text)
  end
end
