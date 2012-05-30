require 'spec_helper'

describe RecipientsController do  
  render_views
  
  describe "POST 'create'" do

    let(:user) { FactoryGirl.create(:user) }
    let(:cusn) { FactoryGirl.create(:desk, name: "CUS North", abrev: "CUSN", job_type: "td") }

    context "for non-signed in users" do
      it "denies access" do
        post :create, desk_id: cusn.id, format: :js
        response.should redirect_to(signin_path)
      end
    end

    context "without a valid desk id" do
      before(:each) { test_sign_in(user) }
      it "creates not a recipient" do
        lambda do
          post :create, desk_id: 0, format: :js
        end.should_not change(Recipient, :count)
      end
    end

    context "with valid desk_id" do
      before(:each) { test_sign_in(user) }
      it "returns http success" do
        post :create, desk_id: cusn.id, format: :js
        response.should be_success
      end

      it "creates a recipient" do
        lambda do
          post :create, desk_id: cusn.id, format: :js
        end.should change(Recipient, :count).by(1)
      end
    end
  end

  describe "DELETE 'destroy'" do
   

    context "for a non-signed in user" do
      before(:each) do
        @user = FactoryGirl.create(:user)
        @recipient = FactoryGirl.create(:recipient, user: @user)
      end
      it "denies access" do
        delete :destroy, id: @recipient.id, format: :js
        response.should redirect_to(signin_path)  
      end
    end

    context "for an unauthorized user" do
      before(:each) do
        @user = FactoryGirl.create(:user)
        @recipient = FactoryGirl.create(:recipient, user: @user)
        test_sign_in(FactoryGirl.create(:user))
      end
      it "denies access" do
        delete :destroy, id: @recipient.id, format: :js
        response.should redirect_to(root_path)  
      end
    end

    context "for an authorized user" do
      before(:each) do
        @user = test_sign_in(FactoryGirl.create(:user))
        @recipient = FactoryGirl.create(:recipient, user: @user)
      end
      it "returns http success" do
        delete :destroy, id: @recipient.id, format: :js
        response.should be_success
      end

      it "destroys a recipient" do
        lambda do
          delete :destroy, id: @recipient.id, format: :js
        end.should change(Recipient, :count).by(-1)
      end
    end
  end
end
