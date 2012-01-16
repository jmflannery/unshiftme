require 'spec_helper'

describe MessagesController do
  render_views

  describe "access control" do

    it "should deny access to 'create' for non-signed in users" do
      post :create, :message => { :content => "what the??" }
      response.should redirect_to(signin_path)
    end

    it "should deny access to 'index' for non-signed in users" do
      get :index, :format => :js
      response.should redirect_to(signin_path)
    end
  end
  
  describe "POST 'create'" do

    before(:each) do
      @user = test_sign_in(Factory(:user))
    end
    
    describe "failure" do

      before(:each) do
        @attr = { :content => "" }
      end

      it "should not create a message" do
        lambda do
          post :create, :message => @attr
        end.should_not change(Message, :count)
      end
    end

    describe "success" do

      before(:each) do
        @attr = { :content => "i like turtles" }
      end

      it "should create a message" do
        lambda do
          post :create, :message => @attr, :format => :js
        end.should change(Message, :count).by(1)
      end
    end
  end
  
  describe "GET 'index'" do
    
    before(:each) do
      @user = test_sign_in(Factory(:user))
    end
    
    it "should be success" do
      get :index, :format => :js, :user_id => @user.id
      response.should be_success
    end

    it "should have a new messages array" do
      get :index, :format => :js, :user_id => @user.id
      messages = assigns(:new_messages)
      messages.should be_kind_of(Array)
    end
  end
end
