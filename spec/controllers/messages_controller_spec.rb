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
        message.should_receive(:set_receivers)
        xhr :post, :create,  message: attr
      end

      it "sets the message's sending workstations" do
        message.should_receive(:set_sender_workstations)
        xhr :post, :create,  message: attr
      end
    end
  end

  describe "GET index" do
    
    let(:cusn) { FactoryGirl.create(:workstation, name: "CUS North", abrev: "CUSN") }
    before(:each) do
      cusn.set_user(user)
    end

    context "with an authenticated user and no params" do

      before { test_sign_in(user) }
      let(:prm) {{ format: :json }}
      
      it "returns HTTP success" do
        get :index, prm 
        response.should be_success
      end
      
      it "gets the current user's messages for the current time" do
        message = mock_model(Message).as_null_object
        #Message.should_receive(:for_user_before).with(user, time).and_return([message])
        Message.should_receive(:for_user_before).and_return([message])
        get :index, prm
      end
    end

    context "with an authenticated user and a supplied start time" do

      before { test_sign_in(user) }
      let(:time) { Time.now }
      let(:prm) {{ start_time: time, format: :json }}

      it "returns HTTP success" do
        get :index, prm 
        response.should be_success
      end
      
      it "gets the current user's messages for the supplied time" do
        message = mock_model(Message).as_null_object
        Message.should_receive(:for_user_before).with(user, time).and_return([message])
        get :index, prm
      end
    end

    context "with an authenticated user and a supplied start time, end time, user_id and workstation_id" do

      before { test_sign_in(user) }
      let(:start_time) { Time.now - 2.hours }
      let(:end_time) { Time.now }
      let(:transcript_user) { FactoryGirl.create(:user) }
      let(:transcript_workstation) { FactoryGirl.create(:workstation) }
      let(:prm) {{ start_time: start_time, end_time: end_time, workstation_id: transcript_workstation.id, user_id: transcript_user.id, format: :json }}

      it "returns HTTP success" do
        get :index, prm
        response.should be_success
      end
      
      it "gets the current user's messages for the current time between the two times" do
        message = mock_model(Message).as_null_object
        Message.should_receive(:for_user_between).with(transcript_user, start_time, end_time).and_return([message])
        get :index, prm
      end
    end

    context "with an unauthenticated user" do

      it "redirects to the signin path" do
        get :index, format: :json
        response.should redirect_to signin_path
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
      message.reload
      message.read_by.should == { user.user_name => user.workstation_names_str }
    end
  end
end
