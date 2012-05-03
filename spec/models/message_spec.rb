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
     
    before(:each) do
      @today_message = FactoryGirl.create(:message, user: @user, created_at: 23.hours.ago) 
      @yesterday_message = FactoryGirl.create(:message, user: @user, created_at: 25.hours.ago) 
    end

    describe "before" do

      it "returns messages created between the given time and 24 hours earlier" do
        todays_messages = Message.before(Time.now)
        todays_messages.should include @today_message
        todays_messages.should_not include @yesterday_message
      end
    end

    describe "between" do

      it "returns messages created between the given from and to times" do
        messages = Message.between(24.hours.ago, 20.hours.ago)
        messages.should include @today_message
        messages.should_not include @yesterday_message
      end
    end
  end

  describe "method" do

    describe "set_recievers" do 

      let(:cusn) { Desk.create!(name: "CUS North", abrev: "CUSN", job_type: "td") }
      let(:aml) { Desk.create!(name: "AML / NOL", abrev: "AML", job_type: "td") }

      let(:user1) { FactoryGirl.create(:user) }

      let(:message) { FactoryGirl.create(:message, user: @user) }

      before do
        user1.authenticate_desk(cusn.abrev => 1)
        FactoryGirl.create(:recipient, user: @user, desk_id: cusn.id)
        FactoryGirl.create(:recipient, user: @user, desk_id: aml.id)
        message.set_recievers
      end

      it "sets message.recievers to an array hashes, with desk_id and user_id" do
        message.recievers.should == [{ desk_id: cusn.id, user_id: user1.id }, { desk_id: aml.id }]
      end
    end
      
    describe "for_user_before" do
      
      let(:cusn) { Desk.create!(name: "CUS North", abrev: "CUSN", job_type: "td") }
      #let(:aml) { Desk.create!(name: "AML / NOL", abrev: "AML", job_type: "td") }

      let(:user1) { FactoryGirl.create(:user) }
      let(:user2) { FactoryGirl.create(:user) }

      let(:message) { FactoryGirl.create(:message, user: @user) }
      let(:message1) { FactoryGirl.create(:message, user: user1) }
      let(:message2) { FactoryGirl.create(:message, user: user2) }

      before(:each) do
        user1.authenticate_desk(cusn.abrev => 1)
        message.set_recievers
        message1.set_recievers
        message2.set_recievers
        #@recipient_user = FactoryGirl.create(:user)
        #other_user = FactoryGirl.create(:user)
        #FactoryGirl.create(:recipient, user: @user, desk_id: cusn.id)
        #FactoryGirl.create(:recipient, user: @user, desk_id: aml.id)

        #@user.recipients.create(recipient_user_id: @recipient_user.id)
        #@message = @user.messages.create(content: "hello world")
        #@message.set_recievers
        #@read_message = @user.messages.create(content: "I read this, world!")
        #@read_message.set_recievers
        #@read_message.mark_read_by(@recipient_user)
        #@recipient_user_message = @recipient_user.messages.create(content: "hello rails")
        #@recipient_user_message.set_recievers
        #@other_user_message = other_user.messages.create(content: "hello ruby")
        #@other_user_message.set_recievers
        #@old_message = FactoryGirl.create(:message, user: @user, created_at: 25.hours.ago) 
        #@old_message.set_recievers
      end

      it "returns messages that were sent or recieved by the given user" do
        messages = Message.for_user_before(user1, Time.now)
        messages.should include message
        messages.should include message1
        messages.should_not include message2
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

    describe "between_for" do

      before(:each) do
        @sent_message = FactoryGirl.create(:message, user: @user)
        @sent_message2 = FactoryGirl.create(:message, user: @user, created_at: 4.hours.ago)
        @sender = FactoryGirl.create(:user)
        FactoryGirl.create(:recipient, user: @sender, recipient_user_id: @user.id)
        @recieved_message = FactoryGirl.create(:message, user: @sender)
        @recieved_message.set_recievers
        @recieved_message2 = FactoryGirl.create(:message, user: @sender, created_at: 4.hours.ago)
        @recieved_message2.set_recievers
        other_user = FactoryGirl.create(:user)
        @other_message = FactoryGirl.create(:message, user: other_user)
        @other_message.set_recievers
      end
      
      it "returns messages that were sent or recieved by the given user" do
        messages = Message.between_for(@user, 1.hour.ago, Time.now)
        messages.should include @sent_message
        messages.should include @recieved_message
        messages.should_not include @other_message
      end
       
      it "returns messages created between the given time and 24 hours earlier than the given time" do
        messages = Message.between_for(@user, 1.hour.ago, Time.now)
        messages.should include @sent_message
        messages.should include @recieved_message
        messages.should_not include @sent_message2
        messages.should_not include @recieved_message2
      end

      it "sets message view_class attribute to 'owner' for each message created by the given user" do
        messages = Message.between_for(@user, 1.hour.ago, Time.now)
        messages.should include @sent_message           
        index = messages.index(@sent_message) 
        messages[index].view_class.should == "message #{messages[index].id} owner"
      end

      it "sets message view_class attribute to 'recieved_message read' for each read message recieved by the given user" do
        @recieved_message.mark_read_by(@user)
        messages = Message.between_for(@user, 1.hour.ago, Time.now)
        messages.should include @recieved_message
        index = messages.index(@recieved_message) 
        messages[index].view_class.should == "message #{messages[index].id} recieved read"
      end

      it "sets message view_class attribute to 'recieved_message unread' for each unread message recieved by the given user" do
        messages = Message.between_for(@user, 1.hour.ago, Time.now)
        messages.should include @recieved_message
        index = messages.index(@recieved_message) 
        messages[index].view_class.should == "message #{messages[index].id} recieved unread"
      end
    end 

    describe "mark_read_by" do

      before(:each) do
        @message = @user.messages.create(@msg_attr)
        @recipient_user = FactoryGirl.create(:user)
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
        @recipient_user = FactoryGirl.create(:user)
        @recipient_user2 = FactoryGirl.create(:user)
        @recipient_user3 = FactoryGirl.create(:user)
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
