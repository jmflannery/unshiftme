require 'spec_helper'

describe Message do

  before(:each) do
    @user = FactoryGirl.create(:user)
    @msg_attr = { :content => "this is just a test" }
    @msg_attr2 = { :content => "of the emergency broadcast system" }
    @msg_attr3 = { :content => "please remain seated in your seates" }
  end
  
  it "creates a new instance given valid attibutes" do
    @user.messages.create!(@msg_attr)
  end
  
  describe "user associations" do

    before(:each) do
      @message = @user.messages.create(@msg_attr)
    end

    it "has a user attribute" do
      @message.should respond_to(:user)
    end

    it "has the right associated user" do
      @message.user_id.should == @user.id
      @message.user.should == @user
    end
  end
  
  describe "validations" do

    it "requires a user id" do
      Message.new(@msg_attr).should_not be_valid
    end

    it "requires nonblank content" do
      @user.messages.build(:content => "  ").should_not be_valid
    end
     
    it "accepts a 300 character message" do
      @user.messages.build(:content => "a" * 300).should be_valid
    end

    it "rejects long content" do
      @user.messages.build(:content => "a" * 301).should_not be_valid
    end
  end

  describe "scope" do

    describe "before" do

      it "returns messages created between the given time and 24 hours earlier" do
        today_message = FactoryGirl.create(:message, user: @user, created_at: 23.hours.ago) 
        yesterday_message = FactoryGirl.create(:message, user: @user, created_at: 25.hours.ago) 
        todays_messages = Message.before(Time.now)
        todays_messages.should include today_message
        todays_messages.should_not include yesterday_message
      end
    end
  end

  describe "method" do

    describe "set_recievers" do 
    
      it "sets message.recievers to the message's recipient's user_ids seperated by commas" do
        other_user = FactoryGirl.create(:user1)
        other_user2 = FactoryGirl.create(:user2)
        FactoryGirl.create(:recipient, :user => @user, :recipient_user_id => other_user.id)
        FactoryGirl.create(:recipient, :user => @user, :recipient_user_id => other_user2.id)
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

      before(:each) do
        @recipient_user = FactoryGirl.create(:user1)
        other_user = FactoryGirl.create(:user2)
        @user.recipients.create(recipient_user_id: @recipient_user.id)
        @message = @user.messages.create(content: "hello world")
        @message.set_recievers
        @read_message = @user.messages.create(content: "I read this, world!")
        @read_message.set_recievers
        @read_message.mark_read_by(@recipient_user)
        @recipient_user_message = @recipient_user.messages.create(content: "hello rails")
        @recipient_user_message.set_recievers
        @other_user_message = other_user.messages.create(content: "hello ruby")
        @other_user_message.set_recievers
        @old_message = FactoryGirl.create(:message, user: @user, created_at: 25.hours.ago) 
        @old_message.set_recievers
      end
      
      it "returns messages that were sent or recieved by the given user" do
        recipient_messages = Message.before_for(@recipient_user, Time.now)
        recipient_messages.should include @message
        recipient_messages.should include @recipient_user_message
        recipient_messages.should_not include @other_user_message
      end
       
      it "returns messages created between the given time and 24 hours earlier than the given time" do
        recipient_messages = Message.before_for(@recipient_user, Time.now)
        recipient_messages.should include @message
        recipient_messages.should_not include @old_message
      end

      it "sets message view_class attribute to 'owner' for each message created by the given user" do
        messages = Message.before_for(@recipient_user, Time.now)
        messages.should include @recipient_user_message           
        index = messages.index(@recipient_user_message) 
        messages[index].view_class.should == "message #{messages[index].id} owner"
      end

      it "sets message view_class attribute to 'recieved_message read' for each read message recieved by the given user" do
        messages = Message.before_for(@recipient_user, Time.now)
        messages.should include @read_message
        index = messages.index(@read_message) 
        messages[index].view_class.should == "message #{messages[index].id} recieved read"
      end

      it "sets message view_class attribute to 'recieved_message unread' for each unread message recieved by the given user" do
        messages = Message.before_for(@recipient_user, Time.now)
        messages.should include @message
        index = messages.index(@message) 
        messages[index].view_class.should == "message #{messages[index].id} recieved unread"
      end
    end 

    describe "mark_read_by" do

      before(:each) do
        @message = @user.messages.create(@msg_attr)
        @recipient_user = FactoryGirl.create(:user1)
      end
      
      it "adds the given user id the message's read by list" do
        @message.mark_read_by @recipient_user
        read_by_list = @message.read_by.split(",")
        read_by_list.should include @recipient_user.id.to_s
      end

      it "does not add duplicates to message's read by list" do
        @message.mark_read_by @recipient_user
        @message.mark_read_by @recipient_user
        read_by_list = @message.read_by.split(",")
        read_by_list.uniq!.should be_nil
      end
    end

    describe "readers" do

      before(:each) do
        @message = @user.messages.create(@msg_attr)
        @recipient_user = FactoryGirl.create(:user1)
        @recipient_user2 = FactoryGirl.create(:user2)
        @recipient_user3 = FactoryGirl.create(:user3)
      end

      it "returns a list of the user names who read the message" do
        @message.mark_read_by @recipient_user
        @message.mark_read_by @recipient_user2
        @message.mark_read_by @recipient_user3
        @message.readers.should == "#{@recipient_user.user_name}, #{@recipient_user2.user_name} and #{@recipient_user3.user_name} read this."
      end
    end
  end
end
