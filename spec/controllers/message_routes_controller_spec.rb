require 'spec_helper'

describe MessageRoutesController do  
  render_views
  
  let(:cusn) { FactoryGirl.create(:workstation, name: "CUS North", abrev: "CUSN", job_type: "td") }
  let(:cuss) { FactoryGirl.create(:workstation, name: "CUS South", abrev: "CUSS", job_type: "td") }
  let(:aml) { FactoryGirl.create(:workstation, name: "AML / NOL", abrev: "AMl", job_type: "td") }
  let(:ydctl) { FactoryGirl.create(:workstation, name: "Yard Control", abrev: "YDCTL", job_type: "ops") }
  let(:ydmstr) { FactoryGirl.create(:workstation, name: "Yard Master", abrev: "YDMSTR", job_type: "ops") }
  let(:glhs) { FactoryGirl.create(:workstation, name: "Glasshouse", abrev: "GLHS", job_type: "ops") }

  describe "POST 'create'" do

    let(:user) { FactoryGirl.create(:user) }

    context "for non-signed in users" do
      it "denies access" do
        post :create, workstation_id: cusn.id, format: :js
        response.should redirect_to(signin_path)
      end
    end

    context "without a valid workstation id" do
      before(:each) { test_sign_in(user) }
      it "does not create a recipient" do
        lambda do
          post :create, workstation_id: 0, format: :js
        end.should_not change(MessageRoute, :count)
      end
    end

    context "with valid workstation_id" do
      before(:each) { test_sign_in(user) }

      it "returns http success" do
        post :create, workstation_id: cusn.id, format: :js
        response.should be_success
      end

      it "creates a recipient" do
        lambda do
          post :create, workstation_id: cusn.id, format: :js
        end.should change(MessageRoute, :count).by(1)
      end

      context "when the recipient user is controlling multiple workstations" do
        let(:recip_user) { FactoryGirl.create(:user) }
        before(:each) do
          test_sign_in(user)
          recip_user.start_jobs([cusn.abrev, cuss.abrev, aml.abrev])
        end

        it "creates a recipient for each workstation controlled by the recipient_user" do
          lambda do
            post :create, workstation_id: cusn.id, format: :js
          end.should change(MessageRoute, :count).by(3)
        end
      end
    end

    context "with workstation_id 'all'" do
      before(:each) do 
        test_sign_in(user)
        FactoryGirl.create(:workstation, name: "CUS North", abrev: "CUSN", job_type: "td")
        FactoryGirl.create(:workstation, name: "CUS South", abrev: "CUSS", job_type: "td")
        FactoryGirl.create(:workstation, name: "AML / NOL", abrev: "AML", job_type: "td")
        FactoryGirl.create(:workstation, name: "Yard Control", abrev: "YDCTL", job_type: "ops")
        FactoryGirl.create(:workstation, name: "Yard Master", abrev: "YDMSTR", job_type: "ops")
        FactoryGirl.create(:workstation, name: "Glasshouse", abrev: "GLHSE", job_type: "ops")
      end

      it "creates a recipient for all existing workstations" do
        post :create, workstation_id: "all", format: :js
        user.recipients.should_not be_empty
        user.recipients.size.should == Workstation.all.size
        Workstation.all.each do |workstation|
          user.should be_messaging workstation.id 
        end
      end
    end
  end

  describe "DELETE 'destroy'" do
      
    let(:user) { FactoryGirl.create(:user) }
   
    context "for a non-signed in user" do
      let(:message_route) { FactoryGirl.create(:message_route, user: user) }

      it "denies access" do
        delete :destroy, id: recipient.id, format: :js
        response.should redirect_to(signin_path)  
      end
    end

    context "for an unauthorized user" do
        
      let(:message_route) { FactoryGirl.create(:message_route, user: user) }
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
        @recipient = FactoryGirl.create(:message_route, user: user, workstation_id: cusn.id)
      end

      it "returns http success" do
        delete :destroy, id: @recipient.id, format: :js
        response.should be_success
      end

      it "destroys a recipient" do
        lambda do
          delete :destroy, id: @recipient.id, format: :js
        end.should change(MessageRoute, :count).by(-1)
      end

      context "when the recipient user is controlling multiple workstations" do

        let(:user) { FactoryGirl.create(:user) }
        let(:recip_user) { FactoryGirl.create(:user) }
        before(:each) do
          test_sign_in(user)
          recip_user.start_jobs([cusn.abrev, cuss.abrev, aml.abrev])
          @cusn_recip = FactoryGirl.create(:message_route, user: user, workstation_id: cusn.id)
          FactoryGirl.create(:message_route, user: user, workstation_id: cuss.id)
          FactoryGirl.create(:message_route, user: user, workstation_id: aml.id)
        end

        it "creates a recipient for each workstation controlled by the recipient_user" do
          lambda do
            delete :destroy, id: @cusn_recip.id, format: :js
          end.should change(MessageRoute, :count).by(-3)
        end
      end
    end

    context "for an authorized user with workstation_id 'all'" do
      before(:each) do 
        @user = test_sign_in(FactoryGirl.create(:user))
        FactoryGirl.create(:workstation, name: "CUS North", abrev: "CUSN", job_type: "td")
        FactoryGirl.create(:workstation, name: "CUS South", abrev: "CUSS", job_type: "td")
        FactoryGirl.create(:workstation, name: "AML / NOL", abrev: "AML", job_type: "td")
        FactoryGirl.create(:workstation, name: "Yard Control", abrev: "YDCTL", job_type: "ops")
        FactoryGirl.create(:workstation, name: "Yard Master", abrev: "YDMSTR", job_type: "ops")
        FactoryGirl.create(:workstation, name: "Glasshouse", abrev: "GLHSE", job_type: "ops")
      end

      it "destroys all of the current user's recipients" do
        @user.add_recipients(Workstation.all)
        @user.recipients.should_not be_empty
        @user.recipients.size.should == Workstation.all.size
        delete :destroy, id: "all", format: :js
        @user.reload
        @user.recipients.should be_empty
      end
    end
  end
end

