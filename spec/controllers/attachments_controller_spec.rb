require 'spec_helper'

describe AttachmentsController do
   
  before(:each) do
    @base_name = "test_file.txt"
    @upload_file = fixture_file_upload("/files/" + @base_name, "text/plain")
  end

  describe "access control" do

    it "should deny access to 'create' for non-signed in users" do
      post :create, :attachment => {:payload => @upload_file}, format: :js 
      response.should redirect_to(signin_path)
    end
  end
  
  describe "XHR POST 'create'" do

    before(:each) do
      @user = test_sign_in(FactoryGirl.create(:user)) 
    end
     
    #describe "failure" do
    #  it "should not create an attachment" do
    #    lambda do
    #      xhr :post, :create, format: :js
    #    end.should_not change(Attachment, :count)
    #  end
    #end

    describe "success" do
    
      it "should create an attachment" do
        lambda do
          xhr :post, :create, :attachment => {:payload => @upload_file}, format: :js
        end.should change(Attachment, :count).by(1)
      end

      it "should create an attachment that belongs to the current user" do
        xhr :post, :create, :attachment => {:payload => @upload_file}, format: :js
        assigns(:attachment).user_id.should == @user.id
      end

      it "should create a message" do
        lambda do
          xhr :post, :create, :attachment => {:payload => @upload_file}, format: :js
        end.should change(Message, :count).by(1)
      end  

      it "should create a message with the file name as content" do
        xhr :post, :create, :attachment => {:payload => @upload_file}, format: :js 
        assigns(:message).content.should == @base_name
      end
   
      it "should link the newly created message and attachment" do
        xhr :post, :create, :attachment => {:payload => @upload_file}, format: :js
        assigns(:message).attachment_id.should == assigns(:attachment).id
      end
    end
  end
end
