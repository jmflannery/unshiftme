require 'spec_helper'

describe Message do

  let(:cusn) { FactoryGirl.create(:workstation, name: "CUS North", abrev: "CUSN", job_type: "td", user: nil) }
  let(:cuss) { FactoryGirl.create(:workstation, name: "CUS South", abrev: "CUSS", job_type: "td", user: nil) }
  let(:aml) { FactoryGirl.create(:workstation, name: "AML / NOL", abrev: "AML", job_type: "td", user: nil) }
  let(:glhs) { FactoryGirl.create(:workstation, name: "Glasshouse", abrev: "GLHS", job_type: "td", user: nil) }

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

  describe "user association" do

    it "belongs to User" do
      subject.should belong_to(:user)
    end

    it "has the right associated user" do
      subject.user_id.should == user.id
      subject.user.should == user
    end
  end
  
  describe "attachment association" do
 
    it "has one attachment" do
      subject.should have_one :attachment
    end
  end

  describe "incoming_receipts/receivers association" do

    before { subject.save }
    let!(:incoming_receipt) { subject.incoming_receipts.create(workstation: cusn) }

    it "should have many incoming_receipts" do
      subject.should have_many :incoming_receipts
    end

    it "should have many receivers" do
      subject.should have_many :receivers
    end

    it "should have a list of workstations who received the message" do
      subject.receivers.should include cusn
      incoming_receipt.message_id.should == subject.id
    end
  end

  describe "outgoing_receipt/sender association" do

    before { subject.save }
    let(:user2) { FactoryGirl.create(:user) }
    let!(:outgoing_receipt) { subject.create_outgoing_receipt(user: user2) }

    it "has one outgoing_receipt" do
      subject.should have_one :outgoing_receipt
    end
    
    it "has the correct outgoing receipt" do
      subject.outgoing_receipt.should == outgoing_receipt
    end
  end

  describe "acknowledgements/readers association" do

    before { subject.save }
    let(:user2) { FactoryGirl.create(:user) }
    let!(:acknowledgement) { subject.acknowledgements.create(user: user2) }

    it "should have many acknowledgements" do
      subject.should have_many :acknowledgements
    end

    it "should have many readers" do
      subject.should have_many :readers
    end

    it "should have a list of users who are readers of the message" do
      subject.readers.should include user2
      acknowledgement.message_id.should == subject.id
    end
  end

  describe "#generate_incoming_receipts" do

    let(:user1) { FactoryGirl.create(:user, user_name: "fred") }

    before do
      FactoryGirl.create(:message_route, user: user, workstation: cusn)
      FactoryGirl.create(:message_route, user: user, workstation: aml)
      cusn.set_user(user1)
      subject.save
    end

    it "generates an incoming receipt for each recipient of the message user including the workstation's user or nil" do
      subject.generate_incoming_receipts
      subject.incoming_receipts[0].workstation.should == cusn
      subject.incoming_receipts[0].user.should == user1
      subject.incoming_receipts[1].workstation.should == aml
      subject.incoming_receipts[1].user.should == nil
    end

    context "when the message has an attaachment" do

      let(:attachment) { FactoryGirl.create(:attachment) }
      before { subject.attach(attachment) }

      it "generates an incoming receipt for each recipient of the message user including the attachment" do
        subject.generate_incoming_receipts
        subject.incoming_receipts[0].workstation.should == cusn
        subject.incoming_receipts[0].user.should == user1
        subject.incoming_receipts[0].attachment.should == attachment
        subject.incoming_receipts[1].workstation.should == aml
        subject.incoming_receipts[1].user.should == nil
        subject.incoming_receipts[1].attachment.should == attachment
      end
    end
  end

  describe "#generate_incoming_receipt" do

    let(:user1) { FactoryGirl.create(:user) }
    before { subject.save }

    context "when the supplied workstation has no controlling user" do

      it "creates an incoming receipt for the message with the supplied workstation and no user" do
        subject.generate_incoming_receipt(aml)
        subject.incoming_receipts[0].workstation.should == aml
        subject.incoming_receipts[0].user.should == nil
        subject.incoming_receipts[0].attachment.should == nil
      end
    end 

    context "when the supplied workstation has a controlling user" do

      before { cusn.set_user(user1) }

      it "creates an incoming receipt for the message with the supplied workstation and it's controlling user" do
        subject.generate_incoming_receipt(cusn)
        subject.incoming_receipts[0].workstation.should == cusn
        subject.incoming_receipts[0].user.should == user1
        subject.incoming_receipts[0].attachment.should == nil
      end
    end

    context "when the message has an attachment" do

      let(:attachment) { FactoryGirl.create(:attachment) }
      before do
        subject.attach(attachment)
        cusn.set_user(user1)
      end

      it "creates an incoming receipt for the message with the supplied workstation and it's controlling user, and the attachment" do
        subject.generate_incoming_receipt(cusn)
        subject.incoming_receipts[0].attachment.should == attachment
        subject.incoming_receipts[0].workstation.should == cusn
        subject.incoming_receipts[0].user.should == user1
      end
    end

    context 'when an optional user is supplied' do

      let(:user2) { FactoryGirl.create(:user) }
      before { cusn.set_user(user1) }

      it "creates an incoming receipt for the message with the supplied user, instead of the workstation's user" do
        subject.generate_incoming_receipt(cusn, user: user2)
        subject.incoming_receipts[0].workstation.should == cusn
        subject.incoming_receipts[0].user.should == user2
      end
    end
  end

  describe "#generate_outgoing_receipt" do

    it "generate's the message's outgoing_receipt" do
      subject.generate_outgoing_receipt
      subject.outgoing_receipt.user.should == user
    end

    context "when the sender is controlling one or more workstations" do
      before do
        cusn.set_user(user)
        aml.set_user(user)
      end

      it "adds the workstation(s) to the receipt" do
        subject.generate_outgoing_receipt
        subject.outgoing_receipt.workstations.should == ["CUSN", "AML"]
      end
    end

    context "when the sender is not controlling any workstations" do
      it "sets the receipt's workstations to an empty array" do
        subject.generate_outgoing_receipt
        subject.outgoing_receipt.workstations.should == []
      end
    end

    context "with an optional attachment" do

      let(:attachment) { FactoryGirl.create(:attachment) }
      before { subject.attach(attachment) }

      it "includes the attachment in the incoming receipt" do
        subject.generate_outgoing_receipt
        expect(subject.outgoing_receipt.attachment).to eq attachment
      end
    end
  end

  describe "#sender_handle" do

    before do
      cusn.set_user(user)
      cuss.set_user(user)
      aml.set_user(user)
      subject.generate_outgoing_receipt
    end
 
    it "should return a formatted list of the message senders workstation's" do
      subject.sender_handle.should == "joe@CUSN,CUSS,AML"
    end
  end

  describe "#attach" do

    let(:attachment) { FactoryGirl.create(:attachment) }

    it "associates the supplied attachment with the message" do
      subject.attach(attachment)
      subject.attachment.should == attachment
    end
  end

  describe "#sent_by_workstations_list" do

    context "when the message's user has workstations" do

      before do
        cusn.set_user(user)
        cuss.set_user(user)
        aml.set_user(user)
        subject.generate_outgoing_receipt
      end
   
      it "should return a formatted list of the message senders workstation's" do
        subject.sent_by_workstations_list.should == "CUSN,CUSS,AML"
      end
    end

    context "when the message's user has no workstations" do

      before { subject.generate_outgoing_receipt }

      it "returns an empty string" do
        subject.sent_by_workstations_list.should == ""
      end
    end
  end

  describe "#sent_by?" do

    let(:user1) { FactoryGirl.create(:user) }
    
    before do
      cusn.set_user(user)
      subject.generate_outgoing_receipt
    end

    it "returns false if the message was not sent by the given user" do
      subject.sent_by?(user1).should be_false
    end

    it "returns true if the message was sent by the given user" do
      subject.sent_by?(user).should be_true
    end
  end

  describe "#mark_read_by" do
    
    let(:recipient_user) { FactoryGirl.create(:user) }

    before(:each) do
      cusn.set_user(recipient_user)
    end
    
    it "assosiates the supplied user as a reader of the message" do
      subject.mark_read_by(recipient_user)
      subject.readers.should include recipient_user
    end

    it "creates a acknowledgement associated with the supplied user" do
      subject.mark_read_by(recipient_user)
      subject.acknowledgements[0].user.should == recipient_user
    end

    it "adds the user's current workstations to the acknowledgement" do
      subject.mark_read_by(recipient_user)
      subject.acknowledgements[0].workstation_ids.should == recipient_user.workstation_ids
    end

    it "does not does not assciate a user as reader twice" do
      subject.mark_read_by(recipient_user)
      subject.mark_read_by(recipient_user)
      subject.readers.size.should == 1
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

  describe "#sent_to?" do

    let(:user1) { FactoryGirl.create(:user) }
    let(:user2) { FactoryGirl.create(:user) }
    let(:recipient_user) { FactoryGirl.create(:user) }
    before { subject.save }

    context "when the message was not sent to the given user, or the given user's workstations" do
      it "returns false" do
        subject.sent_to?(user1).should be_false
      end
    end

    context "when the message was sent to the given user and workstation" do
      before(:each) do
        cusn.set_user(recipient_user)
        FactoryGirl.create(:message_route, user: user, workstation: cusn)
        subject.generate_incoming_receipts
      end

      it "returns true" do
        subject.sent_to?(recipient_user).should be_true
      end
    end
    
    context "when the message was sent to the given user's workstations but no specified user" do
      before(:each) do
        FactoryGirl.create(:message_route, user: user, workstation: cusn)
        subject.generate_incoming_receipts
        cusn.set_user(recipient_user)
      end

      it "returns true" do
        subject.sent_to?(recipient_user).should be_true
      end
    end
    
    context "when the message was sent to the given user's workstations but to a different user" do
      before(:each) do
        cusn.set_user(user2)
        FactoryGirl.create(:message_route, user: user, workstation: cusn)
        subject.generate_incoming_receipts
        user2.leave_workstation
        cusn.set_user(recipient_user)
      end

      it "returns false" do
        subject.sent_to?(recipient_user).should be_false
      end
    end
  end

  describe "#formatted_readers" do
    
    context "with no message readers" do

      it "returns an empty string" do
        subject.formatted_readers.should == ""
      end
    end

    context "with message readers" do

      let(:recipient_user) { FactoryGirl.create(:user) }
      let(:recipient_user1) { FactoryGirl.create(:user) }
      let(:recipient_user2) { FactoryGirl.create(:user) }

      before(:each) do
        cusn.set_user(recipient_user)
        cuss.set_user(recipient_user1)
        aml.set_user(recipient_user2)
        subject.mark_read_by(recipient_user)
        subject.mark_read_by(recipient_user1)
        subject.mark_read_by(recipient_user2)
      end

      it "returns a formated string list of the user's handles who read the message" do
        subject.formatted_readers.should == "#{recipient_user.user_name}@#{recipient_user.workstation_names_str}, " +
          "#{recipient_user1.user_name}@#{recipient_user1.workstation_names_str} and " +
          "#{recipient_user2.user_name}@#{recipient_user2.workstation_names_str} read this."
      end
    end
  end
end

