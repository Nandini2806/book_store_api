require 'rails_helper'
require 'rspec_api_documentation/dsl'      

resource "Reviews" do
  explanation "Reviews Resource"

  post '/reviews' do
    before do
      User.destroy_all
      Book.destroy_all
      @user = User.create(
        user_name: "test1", 
        role: "user", 
        full_name: "test1 user", 
        email: "test1@gmail.com", 
        password: "123456", 
        password_confirmation: "123456"
      )
      auth_headers = @user.create_new_auth_token
      @book = Book.create(
        title: "End of the world",
        genre: "Thrill",
        author: "Amitabh",
        published_year: "1918",
        price: "256",
        quantity: 100
      )
      header "Authorization", auth_headers["Authorization"]
    end 

    context '200' do
      it 'Add a review for a book' do
        review_params = {
          review: {
            book_id: @book.id,
            text: "This is an awesome book.!"
          }
        }
        do_request(review_params)
        status.should eq(200)
        response_body.should eq("{\"message\":\"Review for user #{@user.id} and book #{@book.id} is successfully added!\"}")
      end
    end

    context '400' do
      before do
        User.destroy_all
        Book.destroy_all
        @user = User.create(
          user_name: "test1", 
          role: "user", 
          full_name: "test1 user", 
          email: "test1@gmail.com", 
          password: "123456", 
          password_confirmation: "123456"
        )
        auth_headers = @user.create_new_auth_token
        @book = Book.create(
          title: "End of the world",
          genre: "Thrill",
          author: "Amitabh",
          published_year: "1918",
          price: "256",
          quantity: 100
        )
        @review = ReviewedBook.create(
          user_id: @user.id,
          book_id: @book.id, 
          text: "This is an awesome book.!"
        )
        header "Authorization", auth_headers["Authorization"]
      end
      it 'When User has already added a review for a book' do
        review_params = {
          review: {
            book_id: @book.id,
            text: "This is an awesome book.!"
          }
        }
        do_request(review_params)
        status.should eq(400)
        response_body.should eq('{"message":"You have already added review!"}')
      end
    end
  end
end