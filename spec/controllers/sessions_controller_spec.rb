require 'spec_helper'

describe SessionsController do
  render_views

  describe "GET 'new'" do

    it "should be successful" do
      get 'new'
      response.should be_success
    end

    it "should have the right title" do
      get 'new'
      response.body.should have_selector("title", :content => "Sign in")
    end
  end
  
  describe "POST 'create'" do

    before(:each) do
      Desk.create!(name: "CUS North", abrev: "CUSN", job_type: "td")
      Desk.create!(name: "CUS South", abrev: "CUSS", job_type: "td")
      Desk.create!(name: "AML / NOL", abrev: "AML", job_type: "td")
      Desk.create!(name: "Yard Control", abrev: "YDCTL", job_type: "ops")
      Desk.create!(name: "Yard Master", abrev: "YDMSTR", job_type: "ops")
      Desk.create!(name: "Glasshouse", abrev: "GLHSE", job_type: "ops")
    end
  
    describe "invalid signin" do
  
      before(:each) do
        @attr = { user_name: "XXX", password: "invalid" }
      end
  
      it "should re-render the new page" do
        post :create, @attr
        response.should redirect_to new_session_path
      end
  
      it "should have a flash.now message" do
        post :create, @attr
        flash.now[:error].should =~ /invalid/i
      end
    end
  
    describe "with valid email and password" do
  
      before(:each) do
        @user = FactoryGirl.create(:user)
        @attr = { user_name: @user.user_name, password: @user.password }
      end
  
      it "should sign the user in" do
        post :create, @attr
        controller.current_user.should == @user
        controller.should be_signed_in
      end
  
      it "should redirect to the user show page" do
        post :create, @attr
        response.should redirect_to(user_path(@user))
      end
    end
  end
  
  describe "DELETE 'destroy'" do
  
    it "should sign a user out" do
      test_sign_in(FactoryGirl.create(:user))
      delete :destroy
      controller.should_not be_signed_in
      response.should redirect_to(root_path)
    end
  end
end

