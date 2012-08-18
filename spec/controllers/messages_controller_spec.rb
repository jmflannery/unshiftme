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
        message.should_receive(:set_sent_by)
        xhr :post, :create,  message: attr
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
