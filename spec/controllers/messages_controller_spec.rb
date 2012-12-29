require 'spec_helper'

describe MessagesController do
  render_views

  let(:user) { FactoryGirl.create(:user, user_name: "jack") }
  let(:attr) { { :content => "i like turtles" } }

  describe "access control" do

    it "should deny access to 'create' for non-signed in users" do
      post :create, :message => attr
      response.should redirect_to(signin_path)
    end

    let(:message) { user.messages.create(attr) }
    it "should deny access to 'update' for non-signed in users" do
      put :update, id: message.id, format: :js, remote: true
      response.should redirect_to(signin_path)
    end
  end
  
  describe "POST create" do

    let(:attr) { { "content" => "i like turtles" } }
    let(:message) { mock_model(Message).as_null_object }
    before(:each) do
      test_sign_in(user)
      Message.stub(:new).and_return(message)
    end

    it "creates a new message" do
      Message.should_receive(:new).with(attr, {}).and_return(message)
      xhr :post, :create,  message: attr
    end
    
    context "on successful message save" do
           
      it "broadcasts the message" do
        message.should_receive(:broadcast)
        xhr :post, :create,  message: attr
      end

      it "sets the message's receivers" do
        message.should_receive(:generate_incoming_receipts)
        xhr :post, :create,  message: attr
      end

      it "sets the message's sending workstations" do
        message.should_receive(:generate_outgoing_receipt)
        xhr :post, :create,  message: attr
      end
    end
  end

  describe "GET index" do
    
    let(:st) { "2012-09-19 02:16:00 -0400" }
    let(:et) { "2012-09-19 04:20:00 -0400" }
    let(:start_time) { Time.parse(st) }
    let(:end_time) { Time.parse(et) }
    let(:cusn) { FactoryGirl.create(:workstation, name: "CUS North", abrev: "CUSN") }
    before(:each) { cusn.set_user(user) }

    context "with an unauthenticated user" do
      let(:prm) {{ format: :json }}

      it "redirects to the signin path" do
        get :index, prm 
        response.should redirect_to signin_path
      end
    end
    
    context "with an authenticated user" do
      before { test_sign_in(user) }
      let(:messages) { double("messages").as_null_object }
      let(:prm) {{ format: :json }}

      it "returns HTTP success" do
        get :index, prm 
        response.should be_success
      end
      
      it "gets the current user's messages" do
        messages = double("messages").as_null_object
        User.any_instance.should_receive(:display_messages).with({}).and_return(messages)
        get :index, prm
      end
      
      it "returns the messages as json" do
        messages = mock("messages").as_null_object
        User.any_instance.stub(:display_messages).with({}).and_return(messages)
        messages.should_receive(:as_json)
        get :index, prm
      end

      context "with a supplied start time" do
        before { prm.merge!(start_time: st) }

        it "gets the current user's messages starting with supplied time" do
          messages = double("messages").as_null_object
          User.any_instance.should_receive(:display_messages).with(start_time: start_time).and_return(messages)
          get :index, prm
        end
      end

      context "with a supplied start and end time" do
        before { prm.merge!(start_time: st, end_time: et) }

        it "gets the current user's messages between the two supplied times" do
          messages = double("messages").as_null_object
          User.any_instance.should_receive(:display_messages).with(start_time: start_time, end_time: end_time).and_return(messages)
          get :index, prm
        end
      end
    end
  end

  describe "PUT 'update'" do

    let(:sender) { FactoryGirl.create(:user) }
    let(:message) { sender.messages.create!(attr) }
    let(:cusn) { FactoryGirl.create(:workstation, name: "CUS North", abrev: "CUSN", job_type: "td") }
    before(:each) do
      user.start_job(cusn.abrev)
      test_sign_in(user)
    end

    it "is successful" do
      put :update, id: message.id, format: :jd, remote: true
      response.should be_success
    end

    it "marks the message read by the current user" do
      put :update, id: message.id, format: :jd, remote: true
      message.reload.readers.should include user
    end
  end
end

