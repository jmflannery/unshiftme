require 'spec_helper'

describe AttachmentsController do
   
  before(:each) do
    @file = File.new(Rails.root + "spec/fixtures/files/test_file.txt")
  end

  describe "access control" do

    it "should deny access to 'create' for non-signed in users" do
      post :create, attachment: {payload: @file} 
      response.should redirect_to(signin_path)
    end
  end
  
  describe "POST 'create'" do

    before(:each) do
      @user = test_sign_in(Factory(:user))
    end
    
    it "should create an attachment" do
      lambda do
        post :create, attachment: {payload: @file}, format: :js
      end.should change(Attachment, :count).by(1)
    end

    it "should create an attachment that belongs to the current user" do
      post :create, attachment: {payload: @file}, format: :js
      assigns(:attachment).user_id.should == @user.id
    end

    it "should create a message" do
      lambda do
        post :create, attachment: {payload: @file}, remote: true, format: :js
      end.should change(Message, :count).by(1)
    end  

    it "should create a message with the file name as content" do
      puts File.basename(@file)
      post :create, :attachment => {:payload => @file}, format: :js 
      assigns(:message).content.should == File.basename(@file)
    end 

    it "should link the newly created message and attachment" do
      post :create, attachment: {payload: @file}, remote: true, format: :js 
      assigns(:message).attachment_id.should == assigns(:attachment).id
    end
  end
end
