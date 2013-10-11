require 'spec_helper'

describe Attachment do

  let(:user) { FactoryGirl.create(:user) }
  let(:attr) { { payload: file } }
  let(:file) { File.new(Rails.root + "spec/fixtures/files/test_file.txt") }

  let(:cusn) { FactoryGirl.create(:workstation, name: "CUS North", abrev: "CUSN", job_type: "td", user: nil) }
  
  before(:each) do
    @attachment = user.attachments.build(attr)
  end

  subject { @attachment }

  it { should respond_to(:payload) }
  it { should respond_to(:payload_url) }
  it { should respond_to(:payload_identifier) }

  it { should be_valid }

  describe "user association" do

    before(:each) { @attachment.save }

    it { should respond_to(:user) }

    it "should have the right user associated user" do
      @attachment.user_id.should == user.id
      @attachment.user.should == user
    end
  end

  describe "message association" do

    before(:each) { @attachment.save }

    it "belongs to message" do
      should belong_to :message
    end
  end

  describe "incoming_receipts/receivers association" do

    before { subject.save }
    let!(:incoming_receipt) { subject.incoming_receipts.create(workstation: cusn) }

    it "has many incoming_receipts" do
      should have_many :incoming_receipts
    end

    it "has many receivers" do
      should have_many :receivers
    end

    it "includes the incoming_receipt in it's list of incoming_receipts" do
      subject.incoming_receipts.should include incoming_receipt
    end

    it "should have a list of workstations who received the attachment" do
      subject.receivers.should include cusn
      incoming_receipt.attachment_id.should == subject.id
    end
  end

  describe "outgoing_receipt/sender association" do

    before { subject.save }
    let(:sender) { FactoryGirl.create(:user) }
    let!(:outgoing_receipt) { subject.create_outgoing_receipt(user: sender) }

    it "has one outgoing_receipt" do
      expect(subject).to have_one :outgoing_receipt
    end

     it "has one sender" do
       expect(subject).to have_one :sender
     end

     it "associates the correct outgoing_receipt" do
       expect(subject.outgoing_receipt).to eq outgoing_receipt
     end

     it "associates the the correct user as the sender" do
       expect(subject.sender).to eq sender
     end
  end

  describe '.for_user' do
    
    let(:coworker) { FactoryGirl.create(:user) }
    let(:sent_attachment) { FactoryGirl.create(:attachment, user: user) }
    let(:sent_message) { FactoryGirl.create(:message, user: user, attachment: sent_attachment) }
    let(:received_attachment) { FactoryGirl.create(:attachment, user: coworker) }
    let(:received_message) { FactoryGirl.create(:message, user: coworker, attachment: received_attachment) }
    let(:workstation_received_attachment) { FactoryGirl.create(:attachment, user: coworker) }
    let(:workstation_received_message) { FactoryGirl.create(:message, user: coworker, attachment: workstation_received_attachment) }
    let!(:other_attachment) { FactoryGirl.create(:attachment) }

    before(:each) do
      FactoryGirl.create(:outgoing_receipt, user: user, message: sent_message, attachment: sent_attachment)
      FactoryGirl.create(:incoming_receipt, user: coworker, message: sent_message, attachment: sent_attachment, workstation: nil)

      FactoryGirl.create(:outgoing_receipt, user: coworker, message: received_message)
      FactoryGirl.create(:incoming_receipt, user: user, message: received_message, attachment: received_attachment)

      cusn.set_user(user)
      FactoryGirl.create(:incoming_receipt, workstation: cusn, message: workstation_received_message, attachment: workstation_received_attachment)
    end

    it "returns all attachments sent by the given user" do
      expect(Attachment.for_user(user)).to include sent_attachment
    end

    it "returns all attachments sent to the given user" do
      expect(Attachment.for_user(user)).to include received_attachment
    end

    it "returns all attachments sent to the given user's workstations" do
      expect(Attachment.for_user(user)).to include workstation_received_attachment
    end

    it "does not return return attatchments not sent by or sent to the given user" do
      expect(Attachment.for_user(user)).not_to include other_attachment
    end
  end
end
