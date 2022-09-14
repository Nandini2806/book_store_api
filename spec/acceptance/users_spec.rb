require 'rails_helper'
require 'rspec_api_documentation/dsl'      

resource "Users" do
  explanation "Users Resource"

  get '/users/:id/books' do
    before do 
      @user = User.create(
        user_name: "admin21",
        full_name: "admin1",
        role: "admin",
        email: "admi2n1@gmail.com",
        password: "123456",
        password_confirmation: "123456",
      )
      @book1 = Book.create(
        title: "The dark night",
        genre: "Thrill",
        author: "Jane Austen",
        published_year: "1920",
        price: "256",
        quantity: 100
      )
      @book2 = Book.create(
        title: "The vampire diaries",
        genre: "supernatural",
        author: "Park sen",
        published_year: "1967",
        price: "256",
        quantity: 100
      )
      @buyed_book1 = BuyedBook.create(
        user_id: @user.id,
        book_id: @book1.id,
        quantity: 5
      )
      @buyed_book2 = BuyedBook.create(
        user_id: @user.id,
        book_id: @book2.id,
        quantity: 6
      )
      auth_headers = @user.create_new_auth_token
      header 'Authorization', auth_headers['Authorization']
    end
    let(:id) {@user.id}
    context '200' do
      it 'Show all the books puchased by a user' do
        do_request()
        status.should eq(200)
      end
    end
  end

  get '/users/:id/reviews' do
    before do 
      User.destroy_all
      @user = User.create(
        user_name: "test",
        full_name: "test",
        role: "user",
        email: "test@gmail.com",
        password: "123456",
        password_confirmation: "123456",
      )
      @book = Book.create(
        title: "The dark night",
        genre: "Thrill",
        author: "Jane Austen",
        published_year: "1920",
        price: "256",
        quantity: 100
      )
      @review = ReviewedBook.create(
        user_id: @user.id,
        book_id: @book.id, 
        text: "This is an awesome book.!"
      )
      auth_headers = @user.create_new_auth_token
      header 'Authorization', auth_headers['Authorization']
    end
    let(:id) {@user.id}
    context '200' do
      it 'Show all the reviews puchased by a user' do
        do_request()
        status.should eq(200)
      end
    end

    let(:id) {@user.id}
    context '400' do
      before do 
        User.destroy_all
        @user = User.create(
          user_name: "test",
          full_name: "test",
          role: "user",
          email: "test@gmail.com",
          password: "123456",
          password_confirmation: "123456",
        )
        @book = Book.create(
          title: "The dark night",
          genre: "Thrill",
          author: "Jane Austen",
          published_year: "1920",
          price: "256",
          quantity: 100
        )
        auth_headers = @user.create_new_auth_token
        header 'Authorization', auth_headers['Authorization']
      end
      it 'Show all the reviews puchased by a user' do
        do_request()
        status.should eq(400)
      end
    end
  end

  post '/auth' do
    context '200' do
      it 'Sign up for new user/admin' do
        user_params = {
          user_name: "admin21",
          full_name: "admin1",
          role: "admin",
          email: "admi2n1@gmail.com",
          password: "123456",
          password_confirmation: "123456",
          confirm_success_url: "/"
        }
        do_request(user_params)
        status.should eq(200)
      end
    end
  end

  post '/auth/sign_in' do
    before do 
      User.create(
        user_name: "admin21",
        full_name: "admin1",
        role: "admin",
        email: "admi2n1@gmail.com",
        password: "123456",
        password_confirmation: "123456",
      )
    end
    context '200' do
      it 'Sign in for existing user/admin' do
        user_params = {
          email: "admi2n1@gmail.com",
          password: "123456"
        }
        do_request(user_params)
        status.should eq(200)
      end
    end
  end

  delete '/auth/sign_out' do
    before do 
      @user = User.create(
        user_name: "test",
        full_name: "test",
        role: "user",
        email: "test@gmail.com",
        password: "123456",
        password_confirmation: "123456",
      )
      auth_headers = @user.create_new_auth_token
      header 'Authorization', auth_headers['Authorization']
    end
    context '200' do
      it 'Sign out for existing user/admin' do
        do_request()
        status.should eq(200)
      end
    end
  end

  delete '/users/:id' do
    context '200' do
      before do
        User.destroy_all
        @user = User.create(
          user_name: "testuser",
          full_name: "test user",
          role: "user",
          email: "testuser@gmail.com",
          password: "123456",
          password_confirmation: "123456",
        )
        @adminuser = User.create(
          user_name: "admin1", 
          role: "admin", 
          full_name: "admin1", 
          email: "admin1@gmail.com", 
          password: "123456", 
          password_confirmation: "123456"
        )
        auth_headers_admin = @adminuser.create_new_auth_token
        header "Authorization", auth_headers_admin['Authorization']
      end
      let(:id) {@user.id}
      it "Delete a user, Role: Admin" do
        do_request()
        status.should eq(200)
        response_body.should eq("{\"message\":\"User(s) successfully Deleted!\"}")
      end
    end

    context '200' do
      before do
        User.destroy_all
        @user1 = User.create(
          user_name: "testuser",
          full_name: "test user",
          role: "user",
          email: "testuser@gmail.com",
          password: "123456",
          password_confirmation: "123456",
        )
        @user2 = User.create(
          user_name: "testuser1",
          full_name: "test user2",
          role: "user",
          email: "testuser2@gmail.com",
          password: "123456",
          password_confirmation: "123456",
        )
        @adminuser = User.create(
          user_name: "admin1", 
          role: "admin", 
          full_name: "admin1", 
          email: "admin1@gmail.com", 
          password: "123456", 
          password_confirmation: "123456"
        )
        auth_headers_admin = @adminuser.create_new_auth_token
        header "Authorization", auth_headers_admin['Authorization']
      end
      let (:id) { "#{@user1.id},#{@user2.id}" }
      it "Bulk delete users, Role: Admin" do
        do_request()
        status.should eq(200)
        response_body.should eq("{\"message\":\"User(s) successfully Deleted!\"}")
      end
    end

    context '404' do
      before do
        User.destroy_all
        @adminuser = User.create(
          user_name: "admin1", 
          role: "admin", 
          full_name: "admin1", 
          email: "admin1@gmail.com", 
          password: "123456", 
          password_confirmation: "123456"
        )
        @user = User.create(
          user_name: "testuser",
          full_name: "test user",
          role: "user",
          email: "testuser@gmail.com",
          password: "123456",
          password_confirmation: "123456",
        )
        auth_headers_admin = @adminuser.create_new_auth_token
        header "Authorization", auth_headers_admin['Authorization']
      end
      let (:id) { 77 }
      it "Request to delete a user when user does not exist, Role: Admin" do
        do_request()
        status.should eq(404)
        response_body.should eq("{\"message\":\"User(s) must exist!\"}")
      end
    end

    context '404' do
      before do
        User.destroy_all
        @adminuser = User.create(
          user_name: "admin1", 
          role: "admin", 
          full_name: "admin1", 
          email: "admin1@gmail.com", 
          password: "123456", 
          password_confirmation: "123456"
        )
        @user1 = User.create(
          user_name: "testuser",
          full_name: "test user",
          role: "user",
          email: "testuser@gmail.com",
          password: "123456",
          password_confirmation: "123456",
        )
        @user2 = User.create(
          user_name: "testuser1",
          full_name: "test user2",
          role: "user",
          email: "testuser2@gmail.com",
          password: "123456",
          password_confirmation: "123456",
        )
        auth_headers_admin = @adminuser.create_new_auth_token
        header "Authorization", auth_headers_admin['Authorization']
      end
      let (:id) { "#{@user1.id},#{77}" }
      it "Request to delete a user(s) when one of the user does not exist, Role: Admin" do
        do_request()
        status.should eq(404)
        response_body.should eq("{\"message\":\"User(s) must exist!\"}")
      end
    end
  end
end