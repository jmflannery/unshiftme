require 'spec_helper'

describe Message do

  let(:user) { FactoryGirl.create(:user, user_name: "joe") } 
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
     
    let(:today_message) { FactoryGirl.create(:message, user: user, created_at: 24.hours.ago) }
    let(:yesterday_message) { FactoryGirl.create(:message, user: user, created_at: 25.hours.ago) }

    describe "before" do

      it "returns messages created between the given time and 24 hours earlier" do
        todays_messages = Message.before(1.second.ago)
        todays_messages.should include today_message
        todays_messages.should_not include yesterday_message
      end
    end

    describe "between" do

      it "returns messages created between the given from and to times" do
        messages = Message.between(1441.minutes.ago, 20.hours.ago)
        messages.should include today_message
        messages.should_not include yesterday_message
      end
    end
  end

  describe "#broadcast" do

    let(:cusn) { FactoryGirl.create(:workstation, name: "CUS North", abrev: "CUSN", job_type: "td") }
    let(:cuss) { FactoryGirl.create(:workstation, name: "CUS South", abrev: "CUSS", job_type: "td") }
    let(:glhs) { FactoryGirl.create(:workstation, name: "Glasshouse", abrev: "GLHS", job_type: "td") }
    let(:user1) { FactoryGirl.create(:user) }
    let(:user2) { FactoryGirl.create(:user) }
    let(:message) { FactoryGirl.create(:message, user: user) }

    before(:each) do
      user1.authenticate_workstation(cusn.abrev => 1)
      FactoryGirl.create(:recipient, user: user, workstation_id: cusn.id)
      user2.authenticate_workstation(cuss.abrev => 1)
      FactoryGirl.create(:recipient, user: user, workstation_id: cuss.id)
    end

    it "sends the message to each recipient workstation" do
      recipient_count = user.recipients.size
      PrivatePub.should_receive(:publish_to).exactly(recipient_count).times
      message.broadcast
    end

    it "stores each recipient workstation and user (if one exists) in the serialized 'recievers' hash" do
      message.broadcast
      message.reload
      message.recievers.should == { "CUSN" => user1.user_name, "CUSS" => user2.user_name }
    end

    it "adds the sender's workstation to the recipient list of each of the sender's recipients" do
      user.authenticate_workstation(glhs.abrev => 1)
      message.broadcast
      user1.recipients[0].workstation_id.should == glhs.id
      user2.recipients[0].workstation_id.should == glhs.id
    end

    it "does not broadcast a message more than once to a user working multiple jobs" do
      user1.start_jobs([cusn.abrev, cuss.abrev])
      FactoryGirl.create(:recipient, user: user, workstation_id: cusn.id)
      FactoryGirl.create(:recipient, user: user, workstation_id: cuss.id)
      PrivatePub.should_receive(:publish_to).exactly(1).times
      message.broadcast
    end
  end

  describe "#set_recievers" do 

    let(:cusn) { FactoryGirl.create(:workstation, name: "CUS North", abrev: "CUSN", job_type: "td") }
    let(:aml) { Workstation.create!(name: "AML / NOL", abrev: "AML", job_type: "td") }
    let(:user1) { FactoryGirl.create(:user, user_name: "fred") }
    let(:message) { FactoryGirl.create(:message, user: user) }

    before do
      user1.authenticate_workstation(cusn.abrev => 1)
      FactoryGirl.create(:recipient, user: user, workstation_id: cusn.id)
      FactoryGirl.create(:recipient, user: user, workstation_id: aml.id)
      message.set_recievers
    end

    it "sets message.recievers to an array hashes, with workstation_id and user_id" do
      message.recievers.should == { "CUSN" => "fred", "AML" => "" }
    end
  end

  describe "#set_recieved_by" do

    let(:cusn) { FactoryGirl.create(:workstation, name: "CUS North", abrev: "CUSN", job_type: "td") }
    let(:aml) { FactoryGirl.create(:workstation, name: "AML / NOL", abrev: "AML", job_type: "td", user_id: 0) }
    let(:user1) { FactoryGirl.create(:user, user_name: "herman") }
    let(:message) { FactoryGirl.create(:message, user: user) }

    before(:each) do
      user1.authenticate_workstation(cusn.abrev => 1)
      cusn.reload 
    end

    context "when the recipient workstation has no controlling user" do
      before { message.set_recieved_by(aml) }
      it "adds the workstation abrev as a key to the recievers hash with an empty string as the value" do
        message.recievers.should == { "AML" => "" }
      end
    end 

    context "when the recipient workstation has a controlling user" do
      before { message.set_recieved_by(cusn) }
      it "adds the workstation abrev as a key to the recievers hash with the workstation's controlling user_name as the value" do
        message.recievers.should == { "CUSN" => "herman" }
      end
    end 
  end

  describe "#set_sent_by" do

    let(:cusn) { Workstation.create!(name: "CUS North", abrev: "CUSN", job_type: "td") }
    let(:aml) { Workstation.create!(name: "AML / NOL", abrev: "AML", job_type: "td") }
    let(:message) { FactoryGirl.create(:message, user: user) }
    
    before do
      user.authenticate_workstation(cusn.abrev => 1)
      user.authenticate_workstation(aml.abrev => 1)
      message.set_sent_by
    end

    it "sets message.sent to an array of strings of the workstation_abrev's owned by the message sender " do
      message.sent.should == [cusn.abrev, aml.abrev]
    end
  end

  describe "#sender_handle" do

    let(:cusn) { Workstation.create!(name: "CUS North", abrev: "CUSN", job_type: "td") }
    let(:cuss) { Workstation.create!(name: "CUS South", abrev: "CUSS", job_type: "td") }
    let(:aml) { Workstation.create!(name: "AML / NOL", abrev: "AML", job_type: "td") }
    let(:message) { FactoryGirl.create(:message, user: user) }

    before do
      user.authenticate_workstation(cusn.abrev => 1, cuss.abrev => 1, aml.abrev => 1)
      message.set_sent_by
    end
 
    it "should return a formatted list of the message senders workstation's" do
      message.sender_handle.should == "joe@CUSN,CUSS,AML"
    end
  end

  describe "#sent_by" do

    let(:cusn) { Workstation.create!(name: "CUS North", abrev: "CUSN", job_type: "td") }
    let(:cuss) { Workstation.create!(name: "CUS South", abrev: "CUSS", job_type: "td") }
    let(:aml) { Workstation.create!(name: "AML / NOL", abrev: "AML", job_type: "td") }
    let(:message) { FactoryGirl.create(:message, user: user) }

    before do
      user.authenticate_workstation(cusn.abrev => 1, cuss.abrev => 1, aml.abrev => 1)
      message.set_sent_by
    end
 
    it "should return a formatted list of the message senders workstation's" do
      message.sent_by.should == "CUSN,CUSS,AML"
    end
  end

  describe "#was_sent_by?" do

    let(:cusn) { Workstation.create!(name: "CUS North", abrev: "CUSN", job_type: "td") }
    let(:user1) { FactoryGirl.create(:user) }
    
    before do
      user.authenticate_workstation(cusn.abrev => 1)
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
   
    let(:cusn) { Workstation.create!(name: "CUS North", abrev: "CUSN", job_type: "td") }

    let(:user1) { FactoryGirl.create(:user) }
    let(:user2) { FactoryGirl.create(:user) }

    let(:message) { FactoryGirl.create(:message, user: user) }
    let(:message1) { FactoryGirl.create(:message, user: user1, created_at: 1439.minutes.ago) }
    let(:message2) { FactoryGirl.create(:message, user: user2) }
    let(:old_message) { FactoryGirl.create(:message, user: user, created_at: 25.hours.ago) }

    before(:each) do
      user1.authenticate_workstation(cusn.abrev => 1)
      FactoryGirl.create(:recipient, user: user, workstation_id: cusn.id)
      message.set_recievers
      message1.set_recievers
      message2.set_recievers
      old_message.set_recievers
    end

    it "returns messages that were sent or recieved by the given user" do
      messages = Message.for_user_before(user1, 0.seconds.ago)
      messages.should include message
      messages.should include message1
      messages.should_not include message2
    end
     
    it "returns messages created between the given time and 24 hours earlier than the given time" do
      messages = Message.for_user_before(user1, 0.seconds.ago)
      messages.should include message
      messages.should include message1
      messages.should_not include old_message
    end
  end 

  describe "#for_user_between" do
    
    let(:cusn) { Workstation.create!(name: "CUS North", abrev: "CUSN", job_type: "td") }

    let(:user1) { FactoryGirl.create(:user) }
    let(:user2) { FactoryGirl.create(:user) }

    let(:message) { FactoryGirl.create(:message, user: user) }
    let(:message1) { FactoryGirl.create(:message, user: user1) }
    let(:message2) { FactoryGirl.create(:message, user: user2) }
    let(:old_message) { FactoryGirl.create(:message, user: user, created_at: 25.hours.ago) }

    before(:each) do
      user1.authenticate_workstation(cusn.abrev => 1)
      FactoryGirl.create(:recipient, user: user, workstation_id: cusn.id)
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
  end 

  describe "#set_view_class" do
    let(:message) { FactoryGirl.create(:message, user: user) }

    context "for messages created by the given user" do
      it "sets message view_class attribute to 'message owner'" do
        message.set_view_class(user)
        message.view_class.should == "message msg-#{message.id} owner"
      end
    end

    context "for messages recieved and read by the given user" do
      let(:user1) { FactoryGirl.create(:user) }
      let(:cusn) { FactoryGirl.create(:workstation, name: "CUS North", abrev: "CUSN", job_type: "td") }
      before do
        user1.start_job(cusn.abrev)
        message.set_recieved_by(cusn)
        message.mark_read_by(user1)
      end

      it "sets message view_class attribute to 'message recieved read' " do
        message.set_view_class(user1)
        message.view_class.should == "message msg-#{message.id} recieved read"
      end
    end

    context "for messages recieved and not read by the given user" do
      let(:cusn) { FactoryGirl.create(:workstation, name: "CUS North", abrev: "CUSN", job_type: "td") }
      let(:user1) { FactoryGirl.create(:user) }
      before do
        user1.start_job(cusn.abrev)
        message.set_recieved_by(cusn)
      end
      it "sets message view_class attribute to 'message recieved unread'" do
        message.set_view_class(user1)
        message.view_class.should == "message msg-#{message.id} recieved unread"
      end
    end
  end

  describe "#mark_read_by" do
    
    let(:cusn) { Workstation.create!(name: "CUS North", abrev: "CUSN", job_type: "td") }
    let(:recipient_user) { FactoryGirl.create(:user) }
    let(:message) { FactoryGirl.create(:message, user: user) }

    before(:each) do
      recipient_user.authenticate_workstation(cusn.abrev => 1)
    end
    
    it "adds the given workstation(s) and user to the message's read by list" do
      message.mark_read_by recipient_user
      message.read_by.should include({ recipient_user.user_name => recipient_user.workstation_names_str })
    end

    it "does not add duplicates to message's read by list" do
      message.mark_read_by recipient_user
      message.mark_read_by recipient_user
      message.read_by.delete(recipient_user.user_name)
      message.read_by.should_not have_key(recipient_user.user_name)
    end
  end

  describe "#was_read_by?" do

    let(:cusn) { FactoryGirl.create(:workstation, name: "CUS North", abrev: "CUSN", job_type: "td") }
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

    let(:user1) { FactoryGirl.create(:user) }
    let(:user2) { FactoryGirl.create(:user) }
    let(:cusn) { FactoryGirl.create(:workstation, name: "CUS North", abrev: "CUSN", job_type: "td") }
    let(:recipient_user) { FactoryGirl.create(:user) }
    let(:message) { FactoryGirl.create(:message, user: user) }

    context "when the message was not sent to the given user, or the given user's workstations" do
      it "returns false if the message was not sent to the given user" do
        message.was_sent_to?(user1).should be_false
      end
    end

    context "when the message was sent to the given user and workstation" do
      let(:cusn) { FactoryGirl.create(:workstation, name: "CUS North", abrev: "CUSN", job_type: "td") }
      before(:each) do
        recipient_user.start_job(cusn.abrev)
        FactoryGirl.create(:recipient, user: user, workstation_id: cusn.id)
        message.set_recievers
      end
      it "returns true" do
        message.was_sent_to?(recipient_user).should be_true
      end
    end
    
    context "when the message was sent to the given user's workstations but no specified user" do
      before(:each) do
        FactoryGirl.create(:recipient, user: user, workstation_id: cusn.id)
        message.set_recievers
        recipient_user.start_job(cusn.abrev)
      end
      it "returns true" do
        message.was_sent_to?(recipient_user).should be_true
      end
    end
    
    context "when the message was sent to the given user's workstations but to a different user" do
      before(:each) do
        user2.start_job(cusn.abrev)
        FactoryGirl.create(:recipient, user: user, workstation_id: cusn.id)
        message.set_recievers
        user2.leave_workstation
        recipient_user.start_job(cusn.abrev)
      end
      it "returns false" do
        message.was_sent_to?(recipient_user).should be_false
      end
    end
  end

  describe "#readers" do
    let(:message) { FactoryGirl.create(:message, user: user) }
    
    context "with no message readers" do

      it "returns an empty string" do
        message.readers.should == ""
      end
    end

    context "with message readers" do

      let(:cusn) { FactoryGirl.create(:workstation, name: "CUS North", abrev: "CUSN", job_type: "td") }
      let(:cuss) { FactoryGirl.create(:workstation, name: "CUS South", abrev: "CUSS", job_type: "td") }
      let(:aml) { FactoryGirl.create(:workstation, name: "AML / NOL", abrev: "AML", job_type: "td") }
      let(:recipient_user) { FactoryGirl.create(:user) }
      let(:recipient_user1) { FactoryGirl.create(:user) }
      let(:recipient_user2) { FactoryGirl.create(:user) }

      before(:each) do
        recipient_user.authenticate_workstation(cusn.abrev => 1)
        recipient_user1.authenticate_workstation(cuss.abrev => 1)
        recipient_user2.authenticate_workstation(aml.abrev => 1)
        message.mark_read_by(recipient_user)
        message.mark_read_by(recipient_user1)
        message.mark_read_by(recipient_user2)
      end

      it "returns a formated string list of the user's handles who read the message" do
        message.readers.should == "#{recipient_user.user_name}@#{recipient_user.workstation_names_str}, " +
          "#{recipient_user1.user_name}@#{recipient_user1.workstation_names_str} and " +
          "#{recipient_user2.user_name}@#{recipient_user2.workstation_names_str} read this."
      end
    end
  end
end

