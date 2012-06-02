require 'spec_helper'

describe Message do

  let(:user) { FactoryGirl.create(:user) } 
  let(:message) { user.messages.new(content: "this is THAT message") }
  
  it "creates a new instance given valid attibutes" do
    message.save
  end
  
  describe "user associations" do

    before(:each) do
      message.save
    end

    it "has a user attribute" do
      message.should respond_to(:user)
    end

    it "has the right associated user" do
      message.user_id.should == user.id
      message.user.should == user
    end
  end
  
  describe "validations" do

    it "requires a user id" do
      Message.new(@msg_attr).should_not be_valid
    end

    it "requires nonblank content" do
      user.messages.build(:content => "  ").should_not be_valid
    end
     
    it "accepts a 300 character message" do
      user.messages.build(:content => "a" * 300).should be_valid
    end

    it "rejects long content" do
      user.messages.build(:content => "a" * 301).should_not be_valid
    end
  end

  describe "scope" do
     
    let(:today_message) { FactoryGirl.create(:message, user: user, created_at: 23.hours.ago) }
    let(:yesterday_message) { FactoryGirl.create(:message, user: user, created_at: 25.hours.ago) }
    
    describe "before" do

      it "returns messages created between the given time and 24 hours earlier" do
        todays_messages = Message.before(Time.now)
        todays_messages.should include today_message
        todays_messages.should_not include yesterday_message
      end
    end

    describe "between" do

      it "returns messages created between the given from and to times" do
        messages = Message.between(24.hours.ago, 20.hours.ago)
        messages.should include today_message
        messages.should_not include yesterday_message
      end
    end
  end

  describe "#broadcast" do

    let(:cusn) { FactoryGirl.create(:desk, name: "CUS North", abrev: "CUSN", job_type: "td") }
    let(:cuss) { FactoryGirl.create(:desk, name: "CUS South", abrev: "CUSS", job_type: "td") }
    let(:user1) { FactoryGirl.create(:user) }
    let(:user2) { FactoryGirl.create(:user) }
    let(:message) { FactoryGirl.create(:message, user: user) }

    before(:each) do
      user1.authenticate_desk(cusn.abrev => 1)
      FactoryGirl.create(:recipient, user: user, desk_id: cusn.id)
      user2.authenticate_desk(cuss.abrev => 1)
      FactoryGirl.create(:recipient, user: user, desk_id: cuss.id)
    end

    it "sends the message to each recipient desk" do
      pending
      message.broadcast
    end
  end

  describe "#set_recievers" do 

    let(:cusn) { Desk.create!(name: "CUS North", abrev: "CUSN", job_type: "td") }
    let(:aml) { Desk.create!(name: "AML / NOL", abrev: "AML", job_type: "td") }
    let(:user1) { FactoryGirl.create(:user) }
    let(:message) { FactoryGirl.create(:message, user: user) }

    before do
      user1.authenticate_desk(cusn.abrev => 1)
      FactoryGirl.create(:recipient, user: user, desk_id: cusn.id)
      FactoryGirl.create(:recipient, user: user, desk_id: aml.id)
      message.set_recievers
    end

    it "sets message.recievers to an array hashes, with desk_id and user_id" do
      message.recievers.should == [{ desk_id: cusn.id, user_id: user1.id }, { desk_id: aml.id }]
    end
  end

  describe "#set_sent_by" do

    let(:cusn) { Desk.create!(name: "CUS North", abrev: "CUSN", job_type: "td") }
    let(:aml) { Desk.create!(name: "AML / NOL", abrev: "AML", job_type: "td") }
    let(:message) { FactoryGirl.create(:message, user: user) }
    
    before do
      user.authenticate_desk(cusn.abrev => 1)
      user.authenticate_desk(aml.abrev => 1)
      message.set_sent_by
    end

    it "sets message.sent to an array of strings of the desk_abrev's owned by the message sender " do
      message.sent.should == [cusn.abrev, aml.abrev]
    end
  end

  describe "#sent_by" do

    let(:cusn) { Desk.create!(name: "CUS North", abrev: "CUSN", job_type: "td") }
    let(:cuss) { Desk.create!(name: "CUS South", abrev: "CUSS", job_type: "td") }
    let(:aml) { Desk.create!(name: "AML / NOL", abrev: "AML", job_type: "td") }
    let(:message) { FactoryGirl.create(:message, user: user) }

    before do
      user.authenticate_desk(cusn.abrev => 1)
      user.authenticate_desk(cuss.abrev => 1)
      user.authenticate_desk(aml.abrev => 1)
      message.set_sent_by
    end
 
    it "should return a formatted list of the message senders desk's" do
      message.sent_by.should == "CUSN,CUSS,AML"
    end
  end

  describe "#was_sent_by?" do

    let(:cusn) { Desk.create!(name: "CUS North", abrev: "CUSN", job_type: "td") }
    let(:user1) { FactoryGirl.create(:user) }
    
    before do
      user.authenticate_desk(cusn.abrev => 1)
      @message = FactoryGirl.create(:message, user: user)
      @message.set_sent_by
    end

    it "returns false if the message was not sent by the given user" do
      @message.was_sent_by?(user1).should be_false
    end

    it "returns true if the message was sent by the given user" do
      @message.was_sent_by?(user).should be_true
    end
  end
   
  describe "#for_user_before" do
    
    let(:cusn) { Desk.create!(name: "CUS North", abrev: "CUSN", job_type: "td") }

    let(:user1) { FactoryGirl.create(:user) }
    let(:user2) { FactoryGirl.create(:user) }

    let(:message) { FactoryGirl.create(:message, user: user) }
    let(:message1) { FactoryGirl.create(:message, user: user1) }
    let(:message2) { FactoryGirl.create(:message, user: user2) }
    let(:old_message) { FactoryGirl.create(:message, user: user, created_at: 25.hours.ago) }

    before(:each) do
      user1.authenticate_desk(cusn.abrev => 1)
      FactoryGirl.create(:recipient, user: user, desk_id: cusn.id)
      message.set_recievers
      message1.set_recievers
      message2.set_recievers
      old_message.set_recievers
    end

    it "returns messages that were sent or recieved by the given user" do
      messages = Message.for_user_before(user1, Time.now)
      messages.should include message
      messages.should include message1
      messages.should_not include message2
    end
     
    it "returns messages created between the given time and 24 hours earlier than the given time" do
      messages = Message.for_user_before(user1, Time.now)
      messages.should include message
      messages.should_not include old_message
    end

    context "for messages created by the given user" do
      let(:messages) { Message.for_user_before(user, Time.now) }
      it "sets message view_class attribute to 'owner'" do
        messages.should include message           
        index = messages.index(message) 
        messages[index].view_class.should == "message #{messages[index].id} owner"
      end
    end

    context "for messages recieved and read by the given user" do
      let(:messages) { Message.for_user_before(user1, Time.now) }
      before { message.mark_read_by(user1) }
      it "sets message view_class attribute to 'recieved_message read' " do
        messages.should include message
        index = messages.index(message) 
        messages[index].view_class.should == "message #{messages[index].id} recieved read"
      end
    end

    context "for messages recieved and not read by the given user" do
      let(:messages) { Message.for_user_before(user1, Time.now) }
      it "sets message view_class attribute to 'recieved_message unread'" do
        messages.should include message
        index = messages.index(message) 
        messages[index].view_class.should == "message #{messages[index].id} recieved unread"
      end
    end
  end 

  describe "#for_user_between" do
    
    let(:cusn) { Desk.create!(name: "CUS North", abrev: "CUSN", job_type: "td") }

    let(:user1) { FactoryGirl.create(:user) }
    let(:user2) { FactoryGirl.create(:user) }

    let(:message) { FactoryGirl.create(:message, user: user) }
    let(:message1) { FactoryGirl.create(:message, user: user1) }
    let(:message2) { FactoryGirl.create(:message, user: user2) }
    let(:old_message) { FactoryGirl.create(:message, user: user, created_at: 25.hours.ago) }

    before(:each) do
      user1.authenticate_desk(cusn.abrev => 1)
      FactoryGirl.create(:recipient, user: user, desk_id: cusn.id)
      message.set_recievers
      message1.set_recievers
      message2.set_recievers
      old_message.set_recievers
    end

    it "returns messages that were sent or recieved by the given user" do
      messages = Message.for_user_between(user1, 1.hour.ago, Time.now)
      messages.should include message
      messages.should include message1
      messages.should_not include message2
    end
     
    it "returns messages created between the 2 given times" do
      messages = Message.for_user_between(user1, 24.hours.ago, Time.now)
      messages.should include message
      messages.should_not include old_message
    end

    context "for messages created by the given user" do
      let(:messages) { Message.for_user_between(user, 1.hour.ago, Time.now) }
      it "sets message view_class attribute to 'owner'" do
        messages.should include message           
        index = messages.index(message) 
        messages[index].view_class.should == "message #{messages[index].id} owner"
      end
    end

    context "for messages recieved and read by the given user" do
      let(:messages) { Message.for_user_between(user1, 1.hour.ago, Time.now) }
      before { message.mark_read_by(user1) }
      it "sets message view_class attribute to 'recieved_message read' " do
        messages.should include message
        index = messages.index(message) 
        messages[index].view_class.should == "message #{messages[index].id} recieved read"
      end
    end

    context "for messages recieved and not read by the given user" do
      let(:messages) { Message.for_user_between(user1, 1.hour.ago, Time.now) }
      it "sets message view_class attribute to 'recieved_message unread'" do
        messages.should include message
        index = messages.index(message) 
        messages[index].view_class.should == "message #{messages[index].id} recieved unread"
      end
    end
  end 

  describe "#mark_read_by" do
    
    let(:cusn) { Desk.create!(name: "CUS North", abrev: "CUSN", job_type: "td") }
    let(:recipient_user) { FactoryGirl.create(:user) }
    let(:message) { FactoryGirl.create(:message, user: user) }

    before(:each) do
      recipient_user.authenticate_desk(cusn.abrev => 1)
    end
    
    it "adds the given desk(s) and user to the message's read by list" do
      message.mark_read_by recipient_user
      message.read_by.should include({ recipient_user.user_name => recipient_user.desk_names_str })
    end

    it "does not add duplicates to message's read by list" do
      message.mark_read_by recipient_user
      message.mark_read_by recipient_user
      message.read_by.delete(recipient_user.user_name)
      message.read_by.should_not have_key(recipient_user.user_name)
    end
  end

  describe "#was_read_by?" do

    let(:cusn) { FactoryGirl.create(:desk, name: "CUS North", abrev: "CUSN", job_type: "td") }
    let(:user1) { FactoryGirl.create(:user) }
    let(:recipient_user) { FactoryGirl.create(:user) }
    let(:message) { FactoryGirl.create(:message, user: user) }
    
    before(:each) do
      message.mark_read_by(recipient_user)
    end

    it "returns false if the message was not sent by the given user" do
      message.was_read_by?(user1).should be_false
    end

    it "returns true if the message was sent by the given user" do
      message.was_read_by?(recipient_user).should be_true
    end
  end

  describe "#was_sent_to?" do

    let(:cusn) { FactoryGirl.create(:desk, name: "CUS North", abrev: "CUSN", job_type: "td") }
    let(:user1) { FactoryGirl.create(:user) }
    let(:recipient_user) { FactoryGirl.create(:user) }
    let(:message) { FactoryGirl.create(:message, user: user) }
    
    before(:each) do
      recipient_user.authenticate_desk(cusn.abrev => 1)
      FactoryGirl.create(:recipient, user: user, desk_id: cusn.id)
      message.set_recievers
    end

    it "returns false if the message was not sent by the given user" do
      message.was_sent_to?(user1).should be_false
    end

    it "returns true if the message was sent by the given user" do
      message.was_sent_to?(recipient_user).should be_true
    end
  end

  describe "#readers" do
    let(:cusn) { FactoryGirl.create(:desk, name: "CUS North", abrev: "CUSN", job_type: "td") }
    let(:cuss) { FactoryGirl.create(:desk, name: "CUS South", abrev: "CUSS", job_type: "td") }
    let(:aml) { FactoryGirl.create(:desk, name: "AML / NOL", abrev: "AML", job_type: "td") }
    let(:recipient_user) { FactoryGirl.create(:user) }
    let(:recipient_user1) { FactoryGirl.create(:user) }
    let(:recipient_user2) { FactoryGirl.create(:user) }
    let(:message) { FactoryGirl.create(:message, user: user) }

    before(:each) do
      recipient_user.authenticate_desk(cusn.abrev => 1)
      recipient_user1.authenticate_desk(cuss.abrev => 1)
      recipient_user2.authenticate_desk(aml.abrev => 1)
      message.mark_read_by(recipient_user)
      message.mark_read_by(recipient_user1)
      message.mark_read_by(recipient_user2)
    end

    it "returns a formated string list of the user names who read the message" do
      message.readers.should == "#{recipient_user.desk_names_str} (#{recipient_user.user_name}), " +
        "#{recipient_user1.desk_names_str} (#{recipient_user1.user_name}) and " +
        "#{recipient_user2.desk_names_str} (#{recipient_user2.user_name}) read this."
    end
  end
end
