class User < ApplicationRecord
  extend Devise::Models

  # Include default devise modules.
  devise :database_authenticatable, :registerable,
          :recoverable, :rememberable, :validatable
  include DeviseTokenAuth::Concerns::User

  validates :user_name, uniqueness: true

  VALID_EMAIL_REGEX = /\A[\w+\-.]+@[a-z\d\-.]+\.[a-z]+\z/i
	validates :email, presence: true, uniqueness:true, format: { with: VALID_EMAIL_REGEX }

  has_many :buyed_books, dependent: :destroy
  has_many :reviewed_books, dependent: :destroy

  private

end
