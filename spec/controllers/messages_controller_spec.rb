require 'spec_helper'

describe MessagesController do
  render_views

  let(:user) { FactoryGirl.create(:user) }
  let(:attr) { { :content => "i like turtles" } }

  describe "access control" do

    it "should deny access to 'create' for non-signed in users" do
      post :create, :message => attr
      response.should redirect_to(signin_path)
    end

    let(:message) { user.messages.create(attr) }
    it "should deny access to 'update' for non-signed in users" do
      post :update, message_id: message.id, format: :jd, remote: true
      response.should redirect_to(signin_path)
    end
  end
  
  describe "POST 'create'" do

    before(:each) do
      test_sign_in(user)
    end
    
    describe "failure" do

      let(:attr) { { :content => "i like turtles" } }
      it "should not create a message" do
        lambda do
          post :create, :message => @attr, format: :js
        end.should_not change(Message, :count)
      end
    end

    describe "success" do

      it "should create a message" do
        lambda do
          post :create, :message => attr, format: :js
        end.should change(Message, :count).by(1)
      end

      let(:cusn) { FactoryGirl.create(:desk, name: "CUS North", abrev: "CUSN", job_type: "td") }
      let(:cuss) { FactoryGirl.create(:desk, name: "CUS South", abrev: "CUSS", job_type: "td") }
      let(:aml) { FactoryGirl.create(:desk, name: "AML / NOL", abrev: "AML", job_type: "td") }
      let(:recip_user) { FactoryGirl.create(:user, user_name: "samson") }
      before do
        recip_user.start_job(cuss.abrev)
        user.start_job(cusn.abrev)
        FactoryGirl.create(:recipient, user: user, desk_id: cuss.id)
        FactoryGirl.create(:recipient, user: user, desk_id: aml.id)
      end

      it "adds the message sender's desk to the recipient list of all of the message's recipient users" do
        post :create, :message => attr, :format => :js
        recip_user.recipients.size.should == 1
        recip_user.recipients[0].desk_id.should == cusn.id
      end

      it "adds each recipient to the message's recievers hash" do
        post :create, :message => attr, :format => :js
        assigns(:message).recievers.should == { "CUSS" => "samson", "AML" => "" }
      end
    end
  end

  describe "POST 'update'" do

    let(:sender) { FactoryGirl.create(:user) }
    let(:message) { sender.messages.create!(attr) }
    let(:cusn) { FactoryGirl.create(:desk, name: "CUS North", abrev: "CUSN", job_type: "td") }
    before(:each) do
      user.start_job(cusn.abrev)
      test_sign_in(user)
    end

    it "is successful" do
      post :update, id: message.id, format: :jd, remote: true
      response.should be_success
    end

    it "marks the message read by the current user" do
      post :update, id: message.id, format: :jd, remote: true
      message.reload
      message.read_by.should == { user.user_name => user.desk_names_str }
    end
  end
end
