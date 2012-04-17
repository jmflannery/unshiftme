require 'spec_helper'

describe MessagesController do
  render_views

  describe "access control" do

    it "should deny access to 'create' for non-signed in users" do
      post :create, :message => { :content => "what the??" }
      response.should redirect_to(signin_path)
    end

    it "should deny access to 'update' for non-signed in users" do
      user = Factory(:user)
      message = user.messages.create(:content => "i like turtles")
      post :update, message_id: message.id, format: :jd, remote: true
      response.should redirect_to(signin_path)
    end
  end
  
  describe "POST 'create'" do

    before(:each) do
      @user = test_sign_in(Factory(:user))
    end
    
    describe "failure" do

      before(:each) do
        @attr = { :content => "" }
      end

      it "should not create a message" do
        lambda do
          post :create, :message => @attr, format: :js
        end.should_not change(Message, :count)
      end
    end

    describe "success" do

      before(:each) do
        @attr = { :content => "i like turtles" }
      end

      it "should create a message" do
        lambda do
          post :create, :message => @attr, format: :js
        end.should change(Message, :count).by(1)
      end

      it "should add the message sender to the recipient list of all of the message's recipients" do
        recip_user = Factory(:user)
        recipient = Factory(:recipient, user: @user, recipient_user_id: recip_user.id)
        post :create, :message => @attr, :format => :js
        recip_user.recipients.size.should == 1
        recip_user.recipients[0].recipient_user_id.should == @user.id
      end
    end
  end

  describe "POST 'update'" do

    before(:each) do
      @cur_user = test_sign_in(Factory(:user))
      @sender = Factory(:user)
      @message = @sender.messages.create!(:content => "i like turtles")
    end

    it "is successful" do
      post :update, id: @message.id, format: :jd, remote: true
      response.should be_success
    end

    it "marks the message read by the current user" do
      post :update, id: @message.id, format: :jd, remote: true
      @message.reload
      @message.read_by.should == @cur_user.id.to_s
    end
  end
end
