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

      #it "should render the home page" do
      #  post :create, :message => @attr
      #  response.should render_template('pages/home')
      #end
    end

    describe "success" do

      before(:each) do
        @attr = { :content => "Lorem ipsum" }
      end

      it "should create a message" do
        lambda do
          post :create, :message => @attr
        end.should change(Message, :count).by(1)
      end

      #it "should redirect to the home page" do
      #  post :create, :message => @attr
      #  response.should redirect_to(root_path)
      #end
    end
  end
end
