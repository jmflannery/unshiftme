require 'spec_helper'

describe RecipientsController do  
  render_views
  
  let(:cusn) { FactoryGirl.create(:desk, name: "CUS North", abrev: "CUSN", job_type: "td") }
  let(:cuss) { FactoryGirl.create(:desk, name: "CUS South", abrev: "CUSS", job_type: "td") }
  let(:aml) { FactoryGirl.create(:desk, name: "AML / NOL", abrev: "AMl", job_type: "td") }
  let(:ydctl) { FactoryGirl.create(:desk, name: "Yard Control", abrev: "YDCTL", job_type: "ops") }
  let(:ydmstr) { FactoryGirl.create(:desk, name: "Yard Master", abrev: "YDMSTR", job_type: "ops") }
  let(:glhs) { FactoryGirl.create(:desk, name: "Glasshouse", abrev: "GLHS", job_type: "ops") }

  describe "POST 'create'" do

    let(:user) { FactoryGirl.create(:user) }

    context "for non-signed in users" do
      it "denies access" do
        post :create, desk_id: cusn.id, format: :js
        response.should redirect_to(signin_path)
      end
    end

    context "without a valid desk id" do
      before(:each) { test_sign_in(user) }
      it "does not create a recipient" do
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

      context "when the recipient user is controlling multiple desks" do
        let(:recip_user) { FactoryGirl.create(:user) }
        before(:each) do
          test_sign_in(user)
          recip_user.start_jobs([cusn.abrev, cuss.abrev, aml.abrev])
        end

        it "creates a recipient for each desk controlled by the recipient_user" do
          lambda do
            post :create, desk_id: cusn.id, format: :js
          end.should change(Recipient, :count).by(3)
        end
      end
    end

    context "with desk_id 'all'" do
      before(:each) do 
        test_sign_in(user)
        FactoryGirl.create(:desk, name: "CUS North", abrev: "CUSN", job_type: "td")
        FactoryGirl.create(:desk, name: "CUS South", abrev: "CUSS", job_type: "td")
        FactoryGirl.create(:desk, name: "AML / NOL", abrev: "AML", job_type: "td")
        FactoryGirl.create(:desk, name: "Yard Control", abrev: "YDCTL", job_type: "ops")
        FactoryGirl.create(:desk, name: "Yard Master", abrev: "YDMSTR", job_type: "ops")
        FactoryGirl.create(:desk, name: "Glasshouse", abrev: "GLHSE", job_type: "ops")
      end

      it "creates a recipient for all existing desks" do
        post :create, desk_id: "all", format: :js
        user.recipients.should_not be_empty
        user.recipients.size.should == Desk.all.size
        Desk.all.each do |desk|
          user.should be_messaging desk.id 
        end
      end
    end
  end

  describe "DELETE 'destroy'" do
      
    let(:user) { FactoryGirl.create(:user) }
   
    context "for a non-signed in user" do
      let(:recipient) { FactoryGirl.create(:recipient, user: user) }

      it "denies access" do
        delete :destroy, id: recipient.id, format: :js
        response.should redirect_to(signin_path)  
      end
    end

    context "for an unauthorized user" do
        
      let(:recipient) { FactoryGirl.create(:recipient, user: user) }
      before(:each) do
        test_sign_in(FactoryGirl.create(:user))
      end
      
      it "denies access" do
        delete :destroy, id: recipient.id, format: :js
        response.should redirect_to(root_path)  
      end
      
      it "displays a flash error message" do
        delete :destroy, id: recipient.id, format: :js
        flash[:error].should == "Internal Server Error. Please log in again."
      end
    end

    context "for an authorized user" do
      before(:each) do
        test_sign_in(user)
        @recipient = FactoryGirl.create(:recipient, user: user, desk_id: cusn.id)
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

      context "when the recipient user is controlling multiple desks" do

        let(:user) { FactoryGirl.create(:user) }
        let(:recip_user) { FactoryGirl.create(:user) }
        before(:each) do
          test_sign_in(user)
          recip_user.start_jobs([cusn.abrev, cuss.abrev, aml.abrev])
          @cusn_recip = FactoryGirl.create(:recipient, user: user, desk_id: cusn.id)
          FactoryGirl.create(:recipient, user: user, desk_id: cuss.id)
          FactoryGirl.create(:recipient, user: user, desk_id: aml.id)
        end

        it "creates a recipient for each desk controlled by the recipient_user" do
          lambda do
            delete :destroy, id: @cusn_recip.id, format: :js
          end.should change(Recipient, :count).by(-3)
        end
      end
    end

    context "for an authorized user with desk_id 'all'" do
      before(:each) do 
        @user = test_sign_in(FactoryGirl.create(:user))
        FactoryGirl.create(:desk, name: "CUS North", abrev: "CUSN", job_type: "td")
        FactoryGirl.create(:desk, name: "CUS South", abrev: "CUSS", job_type: "td")
        FactoryGirl.create(:desk, name: "AML / NOL", abrev: "AML", job_type: "td")
        FactoryGirl.create(:desk, name: "Yard Control", abrev: "YDCTL", job_type: "ops")
        FactoryGirl.create(:desk, name: "Yard Master", abrev: "YDMSTR", job_type: "ops")
        FactoryGirl.create(:desk, name: "Glasshouse", abrev: "GLHSE", job_type: "ops")
      end

      it "destroys all of the current user's recipients" do
        @user.add_recipients(Desk.all)
        @user.recipients.should_not be_empty
        @user.recipients.size.should == Desk.all.size
        delete :destroy, id: "all", format: :js
        @user.reload
        @user.recipients.should be_empty
      end
    end
  end
end

