require 'spec_helper'

describe Message do

  before(:each) do
    @user = Factory(:user)
    @user_attr = { :name => "Fred", :full_name => "Fred Savage" }
    @user_attr2 = { :name => "Herman", :full_name => "Herman Munster" }
    @msg_attr = { :content => "this is just a test" }
    @msg_attr2 = { :content => "of the emergency broadcast system" }
    @msg_attr3 = { :content => "please remain seated in your seates" }
  end
  
  it "should create a new instance given valid attibutes" do
    @user.messages.create!(@msg_attr)
  end
  
  describe "user associations" do

    before(:each) do
      @message = @user.messages.create(@msg_attr)
    end

    it "should have a user attribute" do
      @message.should respond_to(:user)
    end

    it "should have the right associated user" do
      @message.user_id.should == @user.id
      @message.user.should == @user
    end
  end
  
  describe "validations" do

    it "should require a user id" do
      Message.new(@msg_attr).should_not be_valid
    end

    it "should require nonblank content" do
      @user.messages.build(:content => "  ").should_not be_valid
    end

    it "should reject long content" do
      @user.messages.build(:content => "a" * 141).should_not be_valid
    end
  end

  describe "scope" do

    describe "before" do

      it "should return messages created between the given time and 24 hours earlier" do
        today_message = Factory(:message, user: @user, created_at: 23.hours.ago) 
        yesterday_message = Factory(:message, user: @user, created_at: 25.hours.ago) 
        todays_messages = Message.before(Time.now)
        todays_messages.should include today_message
        todays_messages.should_not include yesterday_message
      end
    end
  end

  describe "method" do

    describe "set_recievers" do 
    
      it "should set message.recievers to the message's recipient's user_ids seperated by commas" do
        other_user = Factory(:user, @user_attr)
        other_user2 = Factory(:user, @user_attr2)
        Factory(:recipient, :user => @user, :recipient_user_id => other_user.id)
        Factory(:recipient, :user => @user, :recipient_user_id => other_user2.id)
        @message = @user.messages.create!(@msg_attr)
        @message.set_recievers
        recievers = @message.recievers.split(/,/)
        recievers.size.should == @user.recipients.size
        @user.recipients.each do |recipient|
          recievers.should include recipient.recipient_user_id.to_s
        end
      end
    end
   
    describe "before_for" do
      
      it "should return messages sent or recieved by the given user and created between the given date and 24 hours earlier" do
        recipient_user = Factory(:user, @user_attr)
        other_user = Factory(:user, @user_attr2)
        Factory(:recipient, user: @user, recipient_user_id: recipient_user.id)
        message = Factory(:message, user: @user)
        message.set_recievers
        recipient_user_message = Factory(:message, user: recipient_user) 
        recipient_user_message.set_recievers
        other_user_message = Factory(:message, user: other_user) 
        other_user_message.set_recievers 
        recipient_messages = Message.before_for(recipient_user, Time.now)
        recipient_messages.should include message
        recipient_messages.should include recipient_user_message
        recipient_messages.should_not include other_user_message
      end
    end 
  end
end
