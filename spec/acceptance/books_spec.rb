require 'rails_helper'
require 'rspec_api_documentation/dsl'      

resource "Books" do
  explanation "Books Resource"

  get '/books' do
    before do
      Book.destroy_all
      User.destroy_all
      @user = User.create(
        user_name: "test1", 
        role: "user", 
        full_name: "test1 user", 
        email: "test1@gmail.com", 
        password: "123456", 
        password_confirmation: "123456"
      )
      auth_headers = @user.create_new_auth_token
      Book.create(
        title: "End of the world",
        genre: "Thrill",
        author: "Amitabh",
        published_year: "1918",
        price: "256",
        quantity: 100
      )
      Book.create(
        title: "You can win",
        genre: "Inspirational",
        author: "Shiv khera",
        published_year: "2009",
        price: "200",
        quantity: 57
      )
      header "Authorization", auth_headers["Authorization"]
    end 
    context '200' do
      it 'Show the list of all availaible books when no filter is given' do
        do_request()
        status.should eq(200)
        books = Book.all.select(:id, :title, :genre, :author).as_json
        s = "{\"books\":#{books}}".gsub "=>", ":"
        response_body.should eq(s.gsub ", ", ",")
      end

      it 'Show the list of all availaible books when one filter is given (genre/author)' do
        do_request("genre": "Thrill")
        status.should eq(200)
        books = Book.where(genre: "Thrill").select(:id, :title, :genre, :author).as_json
        s = "{\"books\":#{books}}".gsub "=>", ":"
        response_body.should eq(s.gsub ", ", ",")
      end

      it 'Show the list of all availaible books when both genre and author are given as filter' do
        do_request("genre": "Thrill", "author": "Shiv khera")
        status.should eq(200)
        books = Book.where(genre: "Thrill", author: "Shiv khera").select(:id, :title, :genre, :author).as_json
        response_body.should eq("{\"message\":\"There are no books availaible with this filter\"}")
      end
    end    
  end

  post '/books' do
    context '200' do
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
        auth_headers_admin = @adminuser.create_new_auth_token
        header "Authorization", auth_headers_admin['Authorization']
      end
      it "Add a new book, Role:admin" do 
        params_obj = {
          book: {
            title: "Kabhi khushi kabhi gum",
            genre: "Thrill",
            author: "Abishek",
            published_year: "1918",
            price: "256",
            quantity: 100
            }
          }
        do_request(params_obj)
        status.should eq(200)
        response_body.should eq("{\"message\":\"New Book has been Added!\"}")
      end
    end

    context '400' do
      before do
        User.destroy_all
        @user = User.create(
          user_name: "user1", 
          role: "user", 
          full_name: "user 1", 
          email: "user1@gmail.com", 
          password: "123456", 
          password_confirmation: "123456"
        )
        auth_headers_user = @user.create_new_auth_token
        header "Authorization", auth_headers_user['Authorization']
      end
      it "Add a new book, Role:user" do
        params_obj = {
          book: {
            title: "Kabhi khushi kabhi gum",
            genre: "Thrill",
            author: "Abishek",
            published_year: "1918",
            price: "256",
            quantity: 100
            }
          }
        do_request(params_obj)
        status.should eq(400)
        response_body.should eq("{\"message\":\"Cannot add book. You are not an admin\"}")
      end
    end
  end
  
  get '/books/:id/reviews' do
    before do
      User.destroy_all
      @user = User.create(
        user_name: "user2", 
        role: "user", 
        full_name: "user 2", 
        email: "user2@gmail.com", 
        password: "123456", 
        password_confirmation: "123456"
      )
      auth_headers = @user.create_new_auth_token
      @book = Book.create(
        title: "The dark night",
        genre: "Thrill",
        author: "Jane Austen",
        published_year: "1920",
        price: "256",
        quantity: 100
      )
      ReviewedBook.create(
        user_id: @user.id,
        book_id: @book.id,
        text: "This is an awesome book."
      ).save!
      header "Authorization", auth_headers['Authorization']
    end

    context '200' do
      let(:id) {@book.id}
      it "Show all the reviews for a book" do
        do_request()
        status.should eq(200)
        reviews = ReviewedBook.where(book_id: @book.id).select(:id, :text).as_json
        s = "{\"reviews\":#{reviews}}".gsub "=>", ":"
        response_body.should eq(s.gsub ", ", ",")
      end
    end
  end

  put '/books/:id' do
    context '200' do
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
        @book = Book.create(
          title: "The dark night",
          genre: "Thrill",
          author: "Jane Austen",
          published_year: "1920",
          price: "256",
          quantity: 100
        )
        auth_headers_admin = @adminuser.create_new_auth_token
        header "Authorization", auth_headers_admin['Authorization']
      end
      let (:id) { @book.id }
      it "Update quantity of existing book, Role: Admin" do
        do_request({book: {quantity: 24 }})
        status.should eq(200)
        response_body.should eq("{\"message\":\"Quantity updated!\"}")
      end
    end

    context '400' do
      before do
        User.destroy_all
        @user = User.create(
          user_name: "user1", 
          role: "user", 
          full_name: "user 1", 
          email: "user1@gmail.com", 
          password: "123456", 
          password_confirmation: "123456"
        )
        @book = Book.create(
          title: "The dark night",
          genre: "Thrill",
          author: "Jane Austen",
          published_year: "1920",
          price: "256",
          quantity: 100
        )
        auth_headers_user = @user.create_new_auth_token
        header "Authorization", auth_headers_user['Authorization']
      end
      let (:id) { @book.id }
      it "Update quantity of existing book, Role: User" do
        do_request({book: {quantity: 24 }})
        status.should eq(400)
        response_body.should eq("{\"message\":\"Cannot add quantity to book. You are not an admin\"}")
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
        @book = Book.create(
          title: "The dark night",
          genre: "Thrill",
          author: "Jane Austen",
          published_year: "1920",
          price: "256",
          quantity: 100
        )
        auth_headers_admin = @adminuser.create_new_auth_token
        header "Authorization", auth_headers_admin['Authorization']
      end
      let (:id) { 77 }
      it "Request to update quantity of book when book does not exist, Role: Admin" do
        do_request({book: {quantity: 24 }})
        status.should eq(404)
        response_body.should eq("{\"message\":\"Could not update quantity because this book does not exist!\"}")
      end
    end
  end

  delete '/books/:id' do
    context '200' do
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
        @book = Book.create(
          title: "The dark night",
          genre: "Thrill",
          author: "Jane Austen",
          published_year: "1920",
          price: "256",
          quantity: 100
        )
        auth_headers_admin = @adminuser.create_new_auth_token
        header "Authorization", auth_headers_admin['Authorization']
      end
      let (:id) { @book.id }
      it "Delete a book, Role: Admin" do
        do_request()
        status.should eq(200)
        response_body.should eq("{\"message\":\"Book(s) successfully Deleted!\"}")
      end
    end

    context '200' do
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
        auth_headers_admin = @adminuser.create_new_auth_token
        header "Authorization", auth_headers_admin['Authorization']
      end
      let (:id) { "#{@book1.id},#{@book2.id}" }
      it "Bulk delete books, Role: Adimn" do
        do_request()
        status.should eq(200)
        response_body.should eq("{\"message\":\"Book(s) successfully Deleted!\"}")
      end
    end

    context '400' do
      before do
        User.destroy_all
        @user = User.create(
          user_name: "user1", 
          role: "user", 
          full_name: "user1", 
          email: "user1@gmail.com", 
          password: "123456", 
          password_confirmation: "123456"
        )
        @book = Book.create(
          title: "The dark night",
          genre: "Thrill",
          author: "Jane Austen",
          published_year: "1920",
          price: "256",
          quantity: 100
        )
        auth_headers_user = @user.create_new_auth_token
        header "Authorization", auth_headers_user['Authorization']
      end
      let (:id) { @book.id }
      it "Delete a book, Role: User" do
        do_request()
        status.should eq(400)
        response_body.should eq("{\"message\":\"Cannot delete book. You are not an admin\"}")
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
        @book = Book.create(
          title: "The dark night",
          genre: "Thrill",
          author: "Jane Austen",
          published_year: "1920",
          price: "256",
          quantity: 100
        )
        auth_headers_admin = @adminuser.create_new_auth_token
        header "Authorization", auth_headers_admin['Authorization']
      end
      let (:id) { 77 }
      it "Request to delete a book when book does not exist, Role: Admin" do
        do_request()
        status.should eq(404)
        response_body.should eq("{\"message\":\"Book(s) must exist!\"}")
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
        auth_headers_admin = @adminuser.create_new_auth_token
        header "Authorization", auth_headers_admin['Authorization']
      end
      let (:id) { "#{@book1.id},#{77}" }
      it "Request to delete a book(s) when one of the book does not exist, Role: Admin" do
        do_request()
        status.should eq(404)
        response_body.should eq("{\"message\":\"Book(s) must exist!\"}")
      end
    end
  end
end