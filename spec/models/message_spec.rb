require 'spec_helper'

describe Message do

  let(:cusn) { FactoryGirl.create(:workstation, name: "CUS North", abrev: "CUSN", job_type: "td") }
  let(:cuss) { FactoryGirl.create(:workstation, name: "CUS South", abrev: "CUSS", job_type: "td") }
  let(:aml) { FactoryGirl.create(:workstation, name: "AML / NOL", abrev: "AML", job_type: "td") }
  let(:glhs) { FactoryGirl.create(:workstation, name: "Glasshouse", abrev: "GLHS", job_type: "td") }

  let(:user) { FactoryGirl.create(:user, user_name: "joe") } 
  before(:each) do
    @message = user.messages.new(content: "this is THAT message")
  end
  
  subject { @message }
 
  it { should be_valid }
  it { should respond_to(:content) }
  it { should respond_to(:user_id) }

  context "without a user_id" do
    before { subject.user_id = nil }
    it { should_not be_valid }
  end

  context "with blank content" do
    before { subject.content = "     " }
    it { should_not be_valid }
  end

  context "with content 300 char long" do
    before{ subject.content = "a" * 300 }
    it { should be_valid }
  end
  
  context "with content longer than 300 char" do
    before { subject.content = "a" * 301 }
    it { should_not be_valid }
  end

  context "without a user_id" do
    before { subject.user_id = nil }
    it { should_not be_valid }
  end

  describe "user associations" do

    it "has a user attribute" do
      subject.should respond_to(:user)
    end

    it "has the right associated user" do
      subject.user_id.should == user.id
      subject.user.should == user
    end
  end
  
  describe "receiver associations" do
    it { should have_many(:receivers) }
  end
  
  describe "sender_workstation associations" do
    it { should have_many(:sender_workstations) }
  end

  describe "named scope" do

    before(:each) do
      subject.created_at = 1.second.ago
      subject.save
      @yesterday_message = FactoryGirl.create(:message, user: user, created_at: 25.hours.ago)
    end

    describe "between" do

      it "returns messages created between the given time and 24 hours earlier" do
        messages = Message.before(1.second.ago)
        messages.should include subject
        messages.should_not include @yesterday_message
      end
    end

    describe "between" do
    
      it "returns messages created between the given from and to times" do
        messages = Message.between(20.hours.ago, 1.second.ago)
        messages.should include subject
        messages.should_not include @yesterday_message
      end
    end
  end

  describe "#broadcast" do

    let(:user1) { FactoryGirl.create(:user) }
    let(:user2) { FactoryGirl.create(:user) }

    before(:each) do
      user1.start_job(cusn.abrev)
      FactoryGirl.create(:recipient, user: user, workstation_id: cusn.id)
      user2.start_job(cuss.abrev)
      FactoryGirl.create(:recipient, user: user, workstation_id: cuss.id)
      subject.save
    end

    it "sends the message to each recipient workstation" do
      recipient_count = user.recipients.size
      PrivatePub.should_receive(:publish_to).exactly(recipient_count).times
      subject.broadcast
    end

    it "adds the sender's workstation to the recipient list of each of the sender's recipients" do
      user.start_job(glhs.abrev)
      subject.broadcast
      user1.recipients[0].workstation_id.should == glhs.id
      user2.recipients[0].workstation_id.should == glhs.id
    end

    it "does not broadcast a message more than once to a user working multiple jobs" do
      user1.start_job(cuss.abrev)
      PrivatePub.should_receive(:publish_to).exactly(1).times
      subject.broadcast
    end
  end

  describe "#set_receivers" do

    let(:user1) { FactoryGirl.create(:user, user_name: "fred") }

    before do
      FactoryGirl.create(:recipient, user: user, workstation_id: cusn.id)
      FactoryGirl.create(:recipient, user: user, workstation_id: aml.id)
      user1.start_job(cusn.abrev)
      subject.set_receivers
    end

    it "sets message.recievers to an array hashes, with workstation_id and user_id" do
      subject.receivers[0].workstation.should == cusn
      subject.receivers[0].user.should == user1
      subject.receivers[1].workstation.should == aml
      subject.receivers[1].user.should == nil
    end
  end

  describe "#set_received_by" do

    let(:user1) { FactoryGirl.create(:user, user_name: "herman") }

    context "when the recipient workstation has no controlling user" do
      before { subject.set_received_by(aml) }
      it "creates a receiver for the given message with the workstation and no user" do
        subject.receivers[0].workstation.should == aml
        subject.receivers[0].user.should == nil
      end
    end 

    context "when the recipient workstation has a controlling user" do
      before do
        user1.start_job(cusn.abrev)
        subject.set_received_by(cusn.reload)
      end
      it "creates a receiver for the given message with the workstation and the user" do
        subject.receivers[0].workstation.should == cusn
        subject.receivers[0].user.should == user1
      end
    end 
  end

  describe "#set_sender_workstations" do

    before do
      user.start_jobs([cusn.abrev, aml.abrev])
      subject.set_sender_workstations
    end

    it "sets the sender_workstations of the message" do
      subject.sender_workstations[0].workstation.should == cusn
      subject.sender_workstations[1].workstation.should == aml
    end
  end

  describe "#sender_handle" do

    before do
      user.start_jobs([cusn.abrev, cuss.abrev, aml.abrev])
      subject.set_sender_workstations
    end
 
    it "should return a formatted list of the message senders workstation's" do
      subject.sender_handle.should == "joe@CUSN,CUSS,AML"
    end
  end

  describe "#sent_by" do

    before do
      user.start_jobs([cusn.abrev, cuss.abrev, aml.abrev])
      subject.set_sender_workstations
    end
 
    it "should return a formatted list of the message senders workstation's" do
      subject.sent_by.should == "CUSN,CUSS,AML"
    end
  end

  describe "#was_sent_by?" do

    let(:user1) { FactoryGirl.create(:user) }
    
    before do
      user.start_job(cusn.abrev)
      subject.set_sender_workstations
    end

    it "returns false if the message was not sent by the given user" do
      subject.was_sent_by?(user1).should be_false
    end

    it "returns true if the message was sent by the given user" do
      subject.was_sent_by?(user).should be_true
    end
  end

  describe "#set_view_class" do

    context "for messages created by the given user" do
      it "sets message view_class attribute to 'message msg-id owner'" do
        subject.set_view_class(user)
        subject.view_class.should == "message msg-#{subject.id} owner"
      end
    end

    context "for messages recieved and read by the given user" do
      let(:user1) { FactoryGirl.create(:user) }
      before do
        user1.start_job(cusn.abrev)
        subject.set_received_by(cusn)
        subject.mark_read_by(user1)
      end

      it "sets message view_class attribute to 'message msg-id recieved read' " do
        subject.set_view_class(user1)
        subject.view_class.should == "message msg-#{subject.id} recieved read"
      end
    end

    context "for messages recieved and not read by the given user" do
      let(:user1) { FactoryGirl.create(:user) }
      before do
        user1.start_job(cusn.abrev)
        subject.set_received_by(cusn)
      end
      it "sets message view_class attribute to 'message msg-id recieved unread'" do
        subject.set_view_class(user1)
        subject.view_class.should == "message msg-#{subject.id} recieved unread"
      end
    end
  end

  describe "#mark_read_by" do
    
    let(:recipient_user) { FactoryGirl.create(:user) }

    before(:each) do
      recipient_user.start_job(cusn.abrev)
    end
    
    it "adds the given workstation(s) and user to the message's read by list" do
      subject.mark_read_by(recipient_user)
      subject.read_by.should include({ recipient_user.user_name => recipient_user.workstation_names_str })
    end

    it "does not add duplicates to message's read by list" do
      subject.mark_read_by(recipient_user)
      subject.mark_read_by(recipient_user)
      subject.read_by.delete(recipient_user.user_name)
      subject.read_by.should_not have_key(recipient_user.user_name)
    end
  end

  describe "#was_read_by?" do

    let(:user1) { FactoryGirl.create(:user) }
    let(:recipient_user) { FactoryGirl.create(:user) }
    
    before(:each) do
      subject.mark_read_by(recipient_user)
    end

    it "returns false if the message was not sent by the given user" do
      subject.was_read_by?(user1).should be_false
    end

    it "returns true if the message was sent by the given user" do
      subject.was_read_by?(recipient_user).should be_true
    end
  end

  describe "#was_sent_to?" do

    let(:user1) { FactoryGirl.create(:user) }
    let(:user2) { FactoryGirl.create(:user) }
    let(:recipient_user) { FactoryGirl.create(:user) }

    context "when the message was not sent to the given user, or the given user's workstations" do
      it "returns false" do
        subject.was_sent_to?(user1).should be_false
      end
    end

    context "when the message was sent to the given user and workstation" do
      before(:each) do
        recipient_user.start_job(cusn.abrev)
        FactoryGirl.create(:recipient, user: user, workstation_id: cusn.id)
        subject.set_receivers
      end
      it "returns true" do
        subject.was_sent_to?(recipient_user).should be_true
      end
    end
    
    context "when the message was sent to the given user's workstations but no specified user" do
      before(:each) do
        FactoryGirl.create(:recipient, user: user, workstation_id: cusn.id)
        subject.set_receivers
        recipient_user.start_job(cusn.abrev)
      end
      it "returns true" do
        subject.was_sent_to?(recipient_user).should be_true
      end
    end
    
    context "when the message was sent to the given user's workstations but to a different user" do
      before(:each) do
        user2.start_job(cusn.abrev)
        FactoryGirl.create(:recipient, user: user, workstation_id: cusn.id)
        subject.set_receivers
        user2.leave_workstation
        recipient_user.start_job(cusn.abrev)
      end
      it "returns false" do
        subject.was_sent_to?(recipient_user).should be_false
      end
    end
  end

  describe "#readers" do
    
    context "with no message readers" do

      it "returns an empty string" do
        subject.readers.should == ""
      end
    end

    context "with message readers" do

      let(:recipient_user) { FactoryGirl.create(:user) }
      let(:recipient_user1) { FactoryGirl.create(:user) }
      let(:recipient_user2) { FactoryGirl.create(:user) }

      before(:each) do
        recipient_user.start_job(cusn.abrev)
        recipient_user1.start_job(cuss.abrev)
        recipient_user2.start_job(aml.abrev)
        subject.mark_read_by(recipient_user)
        subject.mark_read_by(recipient_user1)
        subject.mark_read_by(recipient_user2)
      end

      it "returns a formated string list of the user's handles who read the message" do
        subject.readers.should == "#{recipient_user.user_name}@#{recipient_user.workstation_names_str}, " +
          "#{recipient_user1.user_name}@#{recipient_user1.workstation_names_str} and " +
          "#{recipient_user2.user_name}@#{recipient_user2.workstation_names_str} read this."
      end
    end
  end

  describe "class method" do
    
    describe "#for_user_before" do
   
      let(:user1) { FactoryGirl.create(:user) }
      let(:user2) { FactoryGirl.create(:user) }

      let(:message1) { FactoryGirl.create(:message, user: user1, created_at: 1439.minutes.ago) }
      let(:message2) { FactoryGirl.create(:message, user: user2) }
      let(:old_message) { FactoryGirl.create(:message, user: user, created_at: 25.hours.ago) }

      before(:each) do
        subject.save
        user1.start_job(cusn.abrev)
        FactoryGirl.create(:recipient, user: user, workstation_id: cusn.id)
        subject.set_receivers
        message1.set_receivers
        message2.set_receivers
        old_message.set_receivers
      end

      it "returns messages that were sent or recieved by the given user" do
        messages = Message.for_user_before(user1, 0.seconds.ago)
        messages.should include subject
        messages.should include message1
        messages.should_not include message2
      end
       
      it "returns messages created between the given time and 24 hours earlier than the given time" do
        messages = Message.for_user_before(user1, 0.seconds.ago)
        messages.should include subject
        messages.should include message1
        messages.should_not include old_message
      end
    end 

    describe "#for_user_between" do
      
      let(:user1) { FactoryGirl.create(:user) }
      let(:user2) { FactoryGirl.create(:user) }

      let(:message1) { FactoryGirl.create(:message, user: user1) }
      let(:message2) { FactoryGirl.create(:message, user: user2) }
      let(:old_message) { FactoryGirl.create(:message, user: user, created_at: 25.hours.ago) }

      before(:each) do
        subject.save
        user1.start_job(cusn.abrev)
        FactoryGirl.create(:recipient, user: user, workstation_id: cusn.id)
        subject.set_receivers
        message1.set_receivers
        message2.set_receivers
        old_message.set_receivers
      end

      it "returns messages that were sent or recieved by the given user" do
        messages = Message.for_user_between(user1, 1.hour.ago, Time.now)
        messages.should include subject
        messages.should include message1
        messages.should_not include message2
      end
       
      it "returns messages created between the 2 given times" do
        messages = Message.for_user_between(user1, 24.hours.ago, Time.now)
        messages.should include subject
        messages.should_not include old_message
      end
    end 
  end
end

