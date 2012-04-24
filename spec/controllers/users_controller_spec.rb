require 'spec_helper'

describe UsersController do
  render_views

  before(:each) do
    @fail_attr = { 
      first_name: "",
      middle_initial: "",
      last_name: "",
      user_name: "",
      email: "",
      password: "",
      password_confirmation: ""
    }
    
    @success_attr = { 
      first_name: "New",
      middle_initial: "X",
      last_name: "User",
      user_name: "nxuser",
      email: "user@example.com",
      password: "foobar",
      password_confirmation: "foobar"
    }
  end

  describe "GET 'new'" do

    it "should be successful" do
      get :new
      response.should be_success
    end

    it "should have the right title" do
      get 'new'
      response.body.should have_selector("title", :content => "Sign Up")
    end
  end

  describe "GET 'show'" do

    before(:each) do
      @user = FactoryGirl.create(:user)
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
      response.body.should have_selector("title", content: "#{@user.first_name} #{@user.middle_initial}. #{@user.last_name}")
    end

    it "should include the users name" do
      get :show, :id => @user
      response.should have_selector("p", content: "#{@user.first_name} #{@user.middle_initial}. #{@user.last_name}")
    end
    
    it "should create a new attachment (for a subsequent create)" do
      get :show, :id => @user
      assigns(:attachment).should be_kind_of(Attachment) 
    end

    it "should have an array of the given user's messages" do
      message = FactoryGirl.create(:message, user: @user)
      message.set_recievers
      other_message = FactoryGirl.create(:message)
      other_message.set_recievers
      get :show, :id => @user
      messages = assigns(:messages)
      messages.should include message
      messages.should_not include other_message
    end

  end

  describe "GET 'index'" do

    before(:each) do
      user1 = test_sign_in(FactoryGirl.create(:user))
      user2 = test_sign_in(FactoryGirl.create(:user))
      @offline_user = FactoryGirl.create(:user)
      @user = test_sign_in(FactoryGirl.create(:user))
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

      it "should not create a user" do
        lambda do
          post :create, :user => @fail_attr
        end.should_not change(User, :count)
      end

      it "should have the right title" do
        post :create, :user => @fail_attr
        response.body.should have_selector("title", :content => "Sign Up")
      end

      it "should render the 'new' page" do
        post :create, :user => @fail_attr
        response.should render_template :new
      end
    end

    describe "success" do

      it "should create a user" do
        lambda do
          post :create, :user => @success_attr
        end.should change(User, :count).by(1)
      end

      it "should redirect to the user show page" do
        post :create, :user => @success_attr
        response.should redirect_to(user_path(assigns(:user)))
      end

      it "should sign the user in" do
        post :create, :user => @success_attr
        controller.should be_signed_in
      end
    end
  end

  describe "GET 'edit'" do

    before(:each) do
      @user = FactoryGirl.create(:user)
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
      @user = FactoryGirl.create(:user)
      test_sign_in(@user)
    end

    describe "failure" do

      it "should render the 'edit' page" do
        put :update, id: @user, user: @fail_attr
        response.should render_template('edit')
      end

      it "should have the right title" do
        put :update, id: @user, user: @fail_attr
        response.body.should have_selector("title", :content => "Edit user")
      end

    end

    describe "success" do

      before(:each) do
        @new_attr = { 
          first_name: "Foo",
          middle_initial: "Z",
          last_name: "Bar",
          user_name: "fzbar",
          email: "foobar@example.com",
          password: "foobar",
          password_confirmation: "foobar"
        }
      end

      it "should change the user's attributes" do
        put :update, id: @user, user: @new_attr
        @user.reload
        @user.first_name.should == @new_attr[:first_name]
        @user.middle_initial.should == @new_attr[:middle_initial]
        @user.last_name.should == @new_attr[:last_name]
        @user.user_name.should == @new_attr[:user_name]
        @user.email.should == @new_attr[:email]
      end

      it "should redirect to the user show page" do
        put :update, id: @user, user: @success_attr
        response.should redirect_to(user_path(@user))
      end

      it "should have a flash message" do
        put :update, id: @user, user: @success_attr
        flash[:success].should =~ /updated/
      end
    end
  end

  describe "authentication of show/edit/update pages" do

    before(:each) do
      @user = FactoryGirl.create(:user)
    end

    describe "for non-signed-in users" do

      it "should deny access to 'show'" do
        get :show, id: @user
        response.should redirect_to(signin_path)
      end

      it "should deny access to 'edit'" do
        get :edit, id: @user
        response.should redirect_to(signin_path)
      end

      it "should deny access to 'update'" do
        put :update, id: @user, user: {}
        response.should redirect_to(signin_path)
      end
    end

    describe "for signed-in users" do

      before(:each) do
        wrong_user = FactoryGirl.create(:user)
        test_sign_in(wrong_user)
      end

      it "should require matching user for 'show'" do
        get :show, id: @user
        response.should redirect_to(root_path)
      end

      it "should require matching user for 'edit'" do
        get :edit, id: @user
        response.should redirect_to(root_path)
      end

      it "should require matching user for 'update'" do
        put :update, id: @user, user: {}
        response.should redirect_to(root_path)
      end
    end
  end
end

