class ReviewedBook < ApplicationRecord
  validates :user_id, uniqueness:  { scope: :book_id, :message => "You have already added review" }

  belongs_to :user
  belongs_to :book

end
