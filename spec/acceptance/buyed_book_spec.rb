require 'rails_helper'
require 'rspec_api_documentation/dsl'      

resource "Buyed Books" do
  explanation "Buyed Books Resource"

  post '/buyed_books' do
    let (:total_price) {512}
    context '200' do
      before do
        User.destroy_all
        Book.destroy_all
        BuyedBook.destroy_all
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
      it 'Buy a book (Successful purchase)' do
        book_params = {
          buyed_book: {
            book_id: @book.id,
            quantity: 2
          }
        }
        do_request(book_params)
        status.should eq(200)
        response_body.should eq("{\"message\":\"You have successfully purchased #{@book[:title]} by written by #{@book[:author]}. Your total price is 512.\"}")
      end
    end

    context '400' do
      before do
        User.destroy_all
        Book.destroy_all
        BuyedBook.destroy_all
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
          quantity: 7
        )
        header "Authorization", auth_headers["Authorization"]
      end 
      it 'Buy a book (Required quantity is more than existing)' do
        book_params = {
          buyed_book: {
            book_id: @book.id,
            quantity: 100
          }
        }
        do_request(book_params)
        status.should eq(400)
        response_body.should eq("{\"message\":\"Sorry, we are out of stock!\"}")
      end
    end

    context '404' do
      before do
        User.destroy_all
        Book.destroy_all
        BuyedBook.destroy_all
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
          quantity: 7
        )
        header "Authorization", auth_headers["Authorization"]
      end 
      it 'Buy a book (Book requested is not availaible)' do
        book_params = {
          buyed_book: {
            book_id: 88,
            quantity: 100
          }
        }
        do_request(book_params)
        status.should eq(404)
        response_body.should eq("{\"message\":\"Could not find a book with id 88\"}")
      end
    end

    let (:total_price) {512}
    context '500' do
      before do
        User.destroy_all
        Book.destroy_all
        BuyedBook.destroy_all
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
        @buyed_book = BuyedBook.create(
          user_id: @user.id,
          book_id: @book.id,
          quantity: 2
        )
        header "Authorization", auth_headers["Authorization"]
      end 
      it 'Buy a book (Already purchased the same book)' do
        book_params = {
          buyed_book: {
            book_id: @book.id,
            quantity: 2
          }
        }
        do_request(book_params)
        status.should eq(500)
        response_body.should eq("{\"message\":\"You have already purchased this book\"}")
      end
    end
  end
end