class Book < ApplicationRecord
  validates :title, uniqueness: { scope: :author }
  
  has_many :buyed_books, dependent: :destroy
  has_many :reviewed_books, dependent: :destroy
end
