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
    @attr = { :content => "value for content" }
  end
  
  it "should create a new instance given valid attibutes" do
    @user.messages.create!(@attr)
  end
  
  describe "user associations" do

    before(:each) do
      @message = @user.messages.create(@attr)
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
      Message.new(@attr).should_not be_valid
    end

    it "should require nonblank content" do
      @user.messages.build(:content => "  ").should_not be_valid
    end

    it "should reject long content" do
      @user.messages.build(:content => "a" * 141).should_not be_valid
    end
  end
  
  describe "set_recievers method" do
    
    before(:each) do
      recip_user1 = Factory(:user, :name => "Fred", :full_name => "Fred Savage")
      recip_user2 = Factory(:user, :name => "Herman", :full_name => "Herman Munster")
      recip1 = Factory(:recipient, :user => @user, :recipient_user_id => recip_user1.id)
      recip2 = Factory(:recipient, :user => @user, :recipient_user_id => recip_user2.id) 
    end

    it "should set the message.recievers to all of the message's user's recipients" do
      message = @user.messages.create!(@attr)
      message.set_recievers
      recievers = message.recievers.split(/,/)
      recipients = @user.recipients
      recievers.size.should == recipients.size
      recipients.each do |recipient|
        recievers.should include recipient.recipient_user_id.to_s
      end
    end 
  end

  describe "mark_sent_to method" do

    before(:each) do
      @other_user = Factory(:user, :name => "Herman", :full_name => "Herman Munster")
      user = Factory(:user, :name => "Fred", :full_name => "Fred Savage")
      @message = user.messages.create!(:content => "this is just a test")
    end
    
    it "should mark the message as sent to the given user" do
      @message.mark_sent_to(@user)
      @message.mark_sent_to(@other_user)
      @message.sent.should include @user.id.to_s
      @message.sent.should include @other_user.id.to_s
    end
  end 

  describe "new_messages_for method" do
   
    before(:each) do
      other_user = Factory(:user, :name => "Herman", :full_name => "Herman Munster")
      @message1 = other_user.messages.create!(:content => "this is just a test")
      @message2 = @user.messages.create!(:content => "of the emergency broadcast system")
    end 

    it "should not return any messages that current user is not a recipient" do
      pending("todo")
    end

    it "should only return messages that the current user is a recipient" do
      pending("todo")
    end

    it "should not return messages already sent" do
      @message1.mark_sent_to(@user)
      @message2.mark_sent_to(@user)
      messages = Message.new_messages_for(@user)
      messages.should_not include @message1
      messages.should_not include @message2
    end

    it "should only return un-sent messages" do
      messages = Message.new_messages_for(@user)
      messages.should include @message1
      messages.should include @message2
    end
  end
end
