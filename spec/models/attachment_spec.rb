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
end
