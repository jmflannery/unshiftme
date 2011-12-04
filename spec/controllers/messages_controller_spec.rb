require 'spec_helper'

describe MessagesController do
  render_views

  describe "access control" do

    it "should deny access to 'create'" do
      post :create
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
          post :create, :message => @attr
        end.should change(Message, :count).by(1)
      end
    end
  end
  
  describe "GET 'index'" do
    
    before(:each) do 
      first = Factory(:message)
      second = Factory(:message, :content => "What the ??")
      third = Factory(:message, :content => "Who the ???")
      
      @some_messages = [first, second, third]
    end
    
    # it "should be success" do
    #   get :index
    #   response.should be_success
    # end
  end
end
