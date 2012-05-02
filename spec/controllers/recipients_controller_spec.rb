require 'spec_helper'

describe RecipientsController do  
  render_views

  describe "access control" do

    it "should deny access to 'create' for non-signed in users" do
      post :create, :format => :js
      response.should redirect_to(signin_path)
    end

    it "should deny access to 'destroy' for non-signed in users" do
      delete :destroy, :id => 0, :format => :js
      response.should redirect_to(signin_path)
    end
  end 

  describe "POST 'create'" do

    let(:user) { FactoryGirl.create(:user) }
    let(:cusn) { FactoryGirl.create(:desk, name: "CUS North", abrev: "CUSN", job_type: "td") }
    before(:each) { test_sign_in(user) }

    it "should be success" do
      post :create, desk_id: cusn.id, format: :js
      response.should be_success
    end

    describe "failure" do

      it "should create not a recipient without a valid desk id" do
        lambda do
          post :create, desk_id: 0, format: :js
        end.should_not change(Recipient, :count)
      end
    end

    describe "success" do

      it "should create a recipient given a desk id" do
        lambda do
          post :create, desk_id: cusn.id, format: :js
        end.should change(Recipient, :count).by(1)
      end
    end
  end

  describe "DELETE 'destroy'" do
   
    before(:each) do
      @user = test_sign_in(FactoryGirl.create(:user))
      @recipient = FactoryGirl.create(:recipient, user: @user)
    end

    it "should be successful" do
      delete :destroy, id: @recipient.id, format: :js
      response.should be_success
    end

    describe "for an unauthorized user" do

      before(:each) { test_sign_in(FactoryGirl.create(:user)) }

      it "should deny access" do
        delete :destroy, id: @recipient.id, format: :js
        response.should redirect_to(root_path)  
      end
    end

    describe "for an authorized user" do

      it "should destroy a recipient" do
        lambda do
          delete :destroy, id: @recipient.id, format: :js
        end.should change(Recipient, :count).by(-1)
      end
    end
  end
end
