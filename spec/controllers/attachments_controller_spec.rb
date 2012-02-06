require 'spec_helper'

describe AttachmentsController do
   
  before(:each) do
    @file = File.new(Rails.root + "spec/fixtures/files/test_file.txt")
  end

  describe "access control" do

    it "should deny access to 'new' for non-signed in users" do
      get :new
      response.should redirect_to(signin_path)
    end

    it "should deny access to 'create' for non-signed in users" do
      post :create, uploaded_file: @file 
      response.should redirect_to(signin_path)
    end
  end
  
  describe "POST 'create'" do

    before(:each) do
      @user = test_sign_in(Factory(:user))
    end
    
    it "should create a attachment" do
      lambda do
        post :create, uploaded_file: @file
      end.should change(Attachment, :count).by(1)
    end  

    it "should create an attachment that belongs to the current user" do
      post :create, uploaded_file: @file
      assigns(:attachment).user_id.should == @user.id
    end

    it "should redirect to the current user's show page" do
      post :create, uploaded_file: @file
      response.should redirect_to user_path(@user)
    end
  end
end
