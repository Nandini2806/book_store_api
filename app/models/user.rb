class User < ApplicationRecord
  extend Devise::Models

  # Include default devise modules.
  devise :database_authenticatable, :registerable,
          :recoverable, :rememberable, :validatable
  include DeviseTokenAuth::Concerns::User

  before_validation :strip_whitespace, only: [:email, :user_name] 
  
  VALID_EMAIL_REGEX = /\A\s*[\w+\-.]+@[a-z\d\-.]+\.[a-z]+\s*\z/i
	validates :email, presence: true, uniqueness:true, format: { with: VALID_EMAIL_REGEX }
  VALID_USERNAME_REGEX = /\A(?![_.])(?!.*[_.]{2})[a-zA-Z0-9._]+(?<![_.])\z/i
  validates :user_name, uniqueness: true, format: {with: VALID_USERNAME_REGEX}


  has_many :buyed_books, dependent: :destroy
  has_many :reviewed_books, dependent: :destroy

  private
  def strip_whitespace
    self.email = self.email.strip unless self.email.nil?
    self.user_name = self.user_name.strip unless self.user_name.nil?
  end

end
