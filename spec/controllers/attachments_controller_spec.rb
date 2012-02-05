require 'spec_helper'

describe AttachmentsController do

  describe "GET 'new'" do
    
    it "should be success" do
      get :new
      response.should be_success
    end
  end

  describe "POST 'create'" do

    before(:each) do
      @user = test_sign_in(Factory(:user))
      @file = File.new(Rails.root + "spec/fixtures/files/test_file.txt")
    end
    
    it "should redirect to the current user's show page" do
      post :create, uploaded_file: @file
      response.should redirect_to user_path(@user)
    end
  end
end
