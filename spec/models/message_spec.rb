# == Schema Information
#
# Table name: messages
#
#  id         :integer         not null, primary key
#  content    :string(255)
#  user_id    :integer
#  reciever   :integer
#  read       :integer
#  time_read  :datetime
#  created_at :datetime
#  updated_at :datetime
#

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
  
  describe "method" do

    before(:each) do
      @other_user = Factory(:user, @user_attr)
      @other_user2 = Factory(:user, @user_attr2)
      Factory(:recipient, :user => @user, :recipient_user_id => @other_user.id)
      Factory(:recipient, :user => @user, :recipient_user_id => @other_user2.id)
      @message = @user.messages.create!(@msg_attr)
      @message2 = @other_user.messages.create!(@msg_attr2)
      @message3 = @other_user2.messages.create!(@msg_attr3)
      @message.set_recievers
      @message2.set_recievers
      @message3.set_recievers
    end

    describe "set_recievers" do 

      it "should set message.recievers to the message's recipient's user_ids seperated by commas" do
        recievers = @message.recievers.split(/,/)
        recipients = @user.recipients
        recievers.size.should == recipients.size
        recipients.each do |recipient|
          recievers.should include recipient.recipient_user_id.to_s
        end
      end
    end 

    describe "mark_sent_to" do
    
      it "should mark the message as sent to the given user" do
        @message2.mark_sent_to(@user)
        @message2.mark_sent_to(@other_user)
        @message2.sent.should include @user.id.to_s
        @message2.sent.should include @other_user.id.to_s  
      end
    end 

    describe "new_messages_for" do

      it "should return new unsent messages that the given user is a recipient of" do
        messages = Message.new_messages_for(@other_user)
        messages.should include @message
        messages.should include @message2
      end

      it "should return new unsent messages created by the given user" do     
        messages = Message.new_messages_for(@user)
        messages.should include @message
      end

      it "should not return any messages that the given user is not a recipient of" do
        messages = Message.new_messages_for(@other_user)
        messages.should_not include @message3        
      end

      it "should not return old messages already sent" do
        @message.mark_sent_to(@other_user)
        @message2.mark_sent_to(@other_user)
        messages = Message.new_messages_for(@other_user)
        messages.should_not include @message
        messages.should_not include @message2
      end
    end
  end
end
