require 'spec_helper'

describe UsersController do
  render_views

  describe "GET 'new'" do

    it "should be successful" do
      get 'new'
      response.should be_success
    end

    it "should have the right title" do
      get 'new'
      response.body.should have_selector("title", :content => "Sign Up")
    end
  end

  describe "GET 'show'" do

    before(:each) do
      @user = Factory(:user)
      test_sign_in(@user)
    end

    it "should be success" do
      get :show, :id => @user
      response.should be_success
    end

    it "should find the right user" do
      get :show, :id => @user
      assigns(:user).should == @user
    end

    it "should have the right title" do
      get :show, :id => @user
      response.body.should have_selector("title", :content => @user.full_name)
    end

    it "should include the users name" do
      get :show, :id => @user
      response.should have_selector("p", :content => @user.full_name)
    end
    
  end

  describe "GET 'index'" do

    before(:each) do
      @offline_user = Factory(:user)
      user1 = test_sign_in(Factory(:user, :name => "Fred", :full_name => "Fred Mertz"))
      user2 = test_sign_in(Factory(:user, :name => "Sam", :full_name => "Sammy Sosa"))
      @user = test_sign_in(Factory(:user, :name => "Frank", :full_name => "Frank N Stein"))
      @users = [user1, user2]
    end

    it "should should be success" do
      get :index, :format => :js
      response.should be_success
    end

    it "should not show non-signed in users" do
      get :index, :format => :js
      users = assigns(:online_users)
      users.should_not include(@offline_user)
    end

    it "should not include the current user" do
      get :index, :format => :js
      users = assigns(:online_users)
      users.should_not include(@user)
    end

    it "should show signed in users" do
      get :index, :format => :js
      users = assigns(:online_users)
      users.should == @users
    end

  end

  describe "POST 'create'" do

    describe "failure" do

      before(:each) do
        @attr = { :name => "", :email => "", :password => "",
                  :password_confirmation => "" }
      end

      it "should not create a user" do
        lambda do
          post :create, :user => @attr
        end.should_not change(User, :count)
      end

      it "should have the right title" do
        post :create, :user => @attr
        response.body.should have_selector("title", :content => "Sign Up")
      end

      it "should render the 'new' page" do
        post :create, :user => @attr
        response.should render_template :new
      end
    end

    describe "success" do

      before(:each) do
        @attr = { :name => "New User", :email => "user@example.com",
                  :password => "foobar", :password_confirmation => "foobar" }
      end

      it "should create a user" do
        lambda do
          post :create, :user => @attr
        end.should change(User, :count).by(1)
      end

      it "should redirect to the user show page" do
        post :create, :user => @attr
        response.should redirect_to(user_path(assigns(:user)))
      end

      it "should sign the user in" do
        post :create, :user => @attr
        controller.should be_signed_in
      end
    end
  end

  describe "GET 'edit'" do

    before(:each) do
      @user = Factory(:user)
      test_sign_in(@user)
    end

    it "should be successful" do
      get :edit, :id => @user
      response.should be_success
    end

    it "should have the right title" do
      get :edit, :id => @user
      response.body.should have_selector("title", :content => "Edit user")
    end
  end

  describe "PUT 'update'" do

    before(:each) do
      @user = Factory(:user)
      test_sign_in(@user)
    end

    describe "failure" do

      before(:each) do
        @attr = { :name => "", :full_name => "", :email => "",
            :password => "", :password_confirmation => ""}
      end

      it "should render the 'edit' page" do
        put :update, :id => @user, :user => @attr
        response.should render_template('edit')
      end

      it "should have the right title" do
        put :update, :id => @user, :user => @attr
        response.body.should have_selector("title", :content => "Edit user")
      end

    end

    describe "success" do

      before(:each) do
        @attr = { :name => "samson", :full_name => "happy samson", :email => "samson@bigboys.org",
            :password => "idigoldladies", :password_confirmation => "idigoldladies"}
      end

      it "should change the user's attributes" do
        put :update, :id => @user, :user => @attr
        @user.reload
        @user.name.should == @attr[:name]
        @user.full_name.should == @attr[:full_name]
        @user.email.should == @attr[:email]
      end

      it "should redirect to the user show page" do
        put :update, :id => @user, :user => @attr
        response.should redirect_to(user_path(@user))
      end

      it "should have a flash message" do
        put :update, :id => @user, :user => @attr
        flash[:success].should =~ /updated/
      end

    end

  end

  describe "authentication of show/edit/update pages" do

    before(:each) do
      @user = Factory(:user)
    end

    describe "for non-signed-in users" do

      it "should deny access to 'show'" do
        get :show, :id => @user
        response.should redirect_to(signin_path)
      end

      it "should deny access to 'edit'" do
        get :edit, :id => @user
        response.should redirect_to(signin_path)
      end

      it "should deny access to 'update'" do
        put :update, :id => @user, :user => {}
        response.should redirect_to(signin_path)
      end
    end

    describe "for signed-in users" do

      before(:each) do
        wrong_user = Factory(:user, :name => "Seamore")
        test_sign_in(wrong_user)
      end

      it "should require matching user for 'show'" do
        get :show, :id => @user
        response.should redirect_to(root_path)
      end

      it "should require matching user for 'edit'" do
        get :edit, :id => @user
        response.should redirect_to(root_path)
      end

      it "should require matching user for 'update'" do
        put :update, :id => @user, :user => {}
        response.should redirect_to(root_path)
      end

    end
  end
end

