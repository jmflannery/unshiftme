require 'spec_helper'

describe RecipientsController do  
  render_views

  describe "access control" do

    it "should deny access to 'create' for non-signed in users" do
      post :create, :format => :js
      response.should redirect_to(signin_path)
    end

    it "should deny access to 'index' for non-signed in users" do
      get :index, :format => :js
      response.should redirect_to(signin_path)
    end

    it "should deny access to 'destroy' for non-signed in users" do
      delete :destroy, :id => 0, :format => :js
      response.should redirect_to(signin_path)
    end
  end 

  describe "POST 'create'" do

    before(:each) do
      @user = test_sign_in(Factory(:user, :name => "cuzit", :full_name => "cousin it"))
    end

    it "should redirect to recipient/index" do
      post :create, user: @user.id, format: :js
      response.should be_redirect
    end

    describe "failure" do

      it "should create not a recipient" do
        lambda do
          post :create, user: 0, format: :js
        end.should_not change(Recipient, :count)
      end
    end

    describe "success" do

      it "should create a recipient" do
        lambda do
          post :create, user: @user.id, format: :js
        end.should change(Recipient, :count).by(1)
      end
    end
  end

  describe "GET 'index'" do

    before(:each) do
      @user = test_sign_in(Factory(:user, :name => "cuzit", :full_name => "cousin it"))
    end

    it "should be successful" do
      get 'index', :format => :js
      response.should be_success
    end

    describe "recipient list" do

      before(:each) do
        recip_user1 = Factory(:user, :name => "Lucy", :full_name => "Lucille Ball")
        recip_user2 = Factory(:user, :name => "Darry", :full_name => "Darryl Strawberry")
        @recip1 = Factory(:recipient, :user => @user, :recipient_user_id => recip_user1.id)
        @recip2 = Factory(:recipient, :user => @user, :recipient_user_id => recip_user2.id)
        @recips = [@recip1, @recip2]
        @non_recip = Factory(:recipient)
      end

      it "should include all recipients" do 
        get :index, :format => :js
        recipients = assigns(:my_recipients) 
        recipients.should == @recips
      end

      it "should not include non-recipients" do
        get :index, :format => :js
        recipients = assigns(:my_recipients)
        recipients.should_not include(@non_recip)
      end
    end
  end

  describe "DELETE 'destroy'" do

    before(:each) do
      @user = Factory(:user, :name => "cuzit", :full_name => "cousin it")
      @recipient = Factory(:recipient, :user => @user)
    end
    
    it "should be successful" do
      test_sign_in(@user)
      delete :destroy, :id => @recipient, :format => :js
      response.should be_success
    end

    describe "for an unauthorized user" do

      before(:each) do
        test_sign_in(Factory(:user))
      end

      it "should deny access" do
        delete :destroy, :id => @recipient
        response.should redirect_to(root_path)  
      end

    end

    describe "for an authorized user" do

      before(:each) do
        test_sign_in(@user)
      end

      it "should destroy a recipient" do
        lambda do
          delete :destroy, :id => @recipient.id, :format => :js
        end.should change(Recipient, :count).by(-1)
      end
    end
  end
end
