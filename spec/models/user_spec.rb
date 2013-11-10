require 'spec_helper'

describe User do

  let!(:cusn) { FactoryGirl.create(:workstation, name: "CUS North", abrev: "CUSN", job_type: "td") }
  let!(:aml) { FactoryGirl.create(:workstation, name: "AML / NOL", abrev: "AML", job_type: "td") }

  before(:each) do 
    @user = User.new(
      user_name: "smith",
      password: "foobar",
      password_confirmation: "foobar",
      normal_workstations: %w(CUSN)
    )
  end

  subject { @user }

  it { should respond_to(:user_name) }
  it { should respond_to(:password) }
  it { should respond_to(:password_confirmation) }
  it { should respond_to(:normal_workstations) }
  it { should respond_to(:admin) }
  it { should respond_to(:authenticate) }
  it { should respond_to(:workstation_names) }

  it { should be_valid }

  it { should validate_presence_of(:user_name) }
  it { subject.save; should validate_uniqueness_of(:user_name) }
  #it { should validate_presence_of(:password) }
  it { should validate_presence_of(:password_confirmation) }
  
  it { should have_secure_password }

  it { should have_many(:workstations) }
  it { should have_many(:messages) }
  it { should have_many(:attachments) }
  it { should have_many(:transcripts) }
  it { should have_many(:message_routes) }
  it { should have_many(:recipients).through(:message_routes) }
  it { should have_many(:incoming_receipts) }
  it { should have_many(:incoming_messages).through(:incoming_receipts) }
  it { should have_many(:outgoing_receipts) }
  it { should have_many(:outgoing_messages).through(:outgoing_receipts) }
  it { should have_many(:acknowledgements) }
  it { should have_many(:read_messages).through(:acknowledgements) }

  describe "the first user to be created" do
    before(:each) { subject.save }
    it "is an admin by default" do
      expect(subject).to be_admin
    end
  end

  describe "subsequently created users" do
    let(:second_user) { FactoryGirl.create(:user) }
    before(:each) { subject.save }

    it "are non-admin by default" do
      expect(second_user).not_to be_admin
    end
  end

  describe "normal workstations" do

    it { should respond_to(:normal_workstations) }

    it "has the right workstations" do
      subject.normal_workstations.should == [cusn.abrev]
    end
  end
  
  describe "#updating_password?" do

    before(:each) { subject.save }

    context "when the user is updating password" do
      before { subject.updating_password! }
      it "returns true" do
        subject.should be_updating_password
      end
    end

    context "when the user is not updating password" do
      it "returns false" do
        subject.should_not be_updating_password
      end
    end
  end

  describe "#updating_password!" do

    before(:each) { subject.save }
    
    it "sets updating_password to true" do
      subject.should_not be_updating_password
      subject.updating_password!
      subject.should be_updating_password
    end
  end
  
  describe "#handle" do

    before(:each) do
      subject.save
      cusn.set_user(subject)
      aml.set_user(subject)
    end

    it "returns a string in the format user_name@workstation,workstation" do
      subject.handle.should == "smith@CUSN,AML"
    end
  end

  describe "#display_messages" do

    let(:sender) { FactoryGirl.create(:user) }
    before(:each) { subject.save }

    it "returns a blank array if the user has no messages" do
      subject.display_messages.should == []
    end

    it "returns messages that were sent by the given user" do
      msg = subject.messages.create(content: "this is a message")
      msg.generate_outgoing_receipt
      subject.display_messages.should include msg
    end

    it "returns messages that were sent to the given user" do
      sender.add_recipient(cusn)
      msg = sender.messages.create(content: "this is a message")
      cusn.set_user(subject)
      msg.generate_incoming_receipts
      subject.display_messages.should include msg
    end

    it "returns messages that were sent to the given user's workstation(s), while those workstation(s) had no user" do
      sender.add_recipient(cusn)
      msg = sender.messages.create(content: "this is a message")
      msg.generate_incoming_receipts
      cusn.set_user(subject)
      subject.display_messages.should include msg
    end

    it "does not return messages older than 24 hours" do
      sender.add_recipient(cusn)
      msg = sender.messages.create(content: "this is a message")
      msg.update_attribute(:created_at, 25.hours.ago)
      msg.generate_incoming_receipts
      cusn.set_user(subject)
      subject.display_messages.should_not include msg
    end

    it "sets the view class of each message" do
      sender.add_recipient(cusn)
      msg = sender.messages.create(content: "this is a message")
      msg.generate_incoming_receipts
      subject.display_messages.each do |message|
        message.view_class.should =~ /message/
      end
    end

    context "if start_time option parameter is supplied" do

      it "does not return messages sent before the supplied start_time" do
        sender.add_recipient(cusn)
        msg = sender.messages.create(content: "this is a message")
        msg.update_attribute(:created_at, 3.hours.ago)
        msg.generate_incoming_receipts
        cusn.set_user(subject)
        subject.display_messages(start_time: 2.hours.ago).should_not include msg
      end
    end

    context "if the end_time option parameter is supplied" do

      it "does not return messages sent after the supplied end_time" do
        sender.add_recipient(cusn)
        msg = sender.messages.create(content: "this is a message")
        msg.update_attribute(:created_at, 1.hours.ago)
        msg.generate_incoming_receipts
        cusn.set_user(subject)
        subject.display_messages(end_time: 2.hours.ago).should_not include msg
      end
    end

    context "if the start_time and end_time option parameters are supplied" do

      it "does not return messages sent before the start_time or after the end_time" do
        sender.add_recipient(cusn)
        msg = sender.messages.create(content: "this is a message")
        msg.update_attribute(:created_at, 3.hours.ago)
        msg2 = sender.messages.create(content: "this is also a message")
        msg.update_attribute(:created_at, 1.hour.ago)
        msg.generate_incoming_receipts
        cusn.set_user(subject)
        subject.display_messages(start_time: 32.hours.ago, end_time: 2.hours.ago).should_not include msg
        subject.display_messages(start_time: 32.hours.ago, end_time: 2.hours.ago).should_not include msg2
      end
    end
  end

  describe "#unreceived_workstation_messages" do

    before(:each) do
      subject.save
      sender.add_recipient(cusn)
    end

    let(:sender) { FactoryGirl.create(:user) }
    let(:msg) { sender.messages.create(content: "this is a message") }
    let(:msg2) { sender.messages.create(content: "this is another message") }
    let(:msg3) { sender.messages.create(content: "yet another message") }
    let(:msg4) { sender.messages.create(content: "the best message") }
    let(:msg5) { sender.messages.create(content: "the worst message") }

    context "without start or end time supplied" do

      before(:each) do
        msg.generate_incoming_receipts
        msg2.update_attribute(:created_at, 23.hours.ago)
        msg2.generate_incoming_receipts
        msg3.update_attribute(:created_at, 25.hours.ago)
        msg3.generate_incoming_receipts
        cusn.set_user(subject)
        msg4.update_attribute(:created_at, 2.hours.ago)
        msg4.generate_incoming_receipts
      end

      it "includes messages sent to the user's workstation(s) while they had no user between the 24 hours ago and the current time" do
        expect(subject.reload.unreceived_workstation_messages).to include msg
        expect(subject.reload.unreceived_workstation_messages).to include msg2
      end

      it "does not include messages sent before 24 hours ago" do
        expect(subject.unreceived_workstation_messages).not_to include msg3
      end

      it "does not include messages sent to the user's workstation(s) while the user was working at the workstation" do
        expect(subject.unreceived_workstation_messages).not_to include msg4
      end
    end

    context "if the start_time and end_time options are supplied" do

      before(:each) do
        msg.update_attribute(:created_at, 11.hours.ago)
        msg.generate_incoming_receipts
        msg2.update_attribute(:created_at, 39.hours.ago)
        msg2.generate_incoming_receipts
        msg3.update_attribute(:created_at, 41.hours.ago)
        msg3.generate_incoming_receipts
        msg4.update_attribute(:created_at, 9.hours.ago)
        msg4.generate_incoming_receipts
        cusn.set_user(subject)
        msg5.update_attribute(:created_at, 39.hours.ago)
        msg5.generate_incoming_receipts
      end

      it "includes messages sent to the user's workstation(s) while they had no user between the start and end times" do
        expect(subject.unreceived_workstation_messages(start_time: 40.hours.ago, end_time: 10.hours.ago)).to include msg
        expect(subject.unreceived_workstation_messages(start_time: 40.hours.ago, end_time: 10.hours.ago)).to include msg2
      end

      it "does not include messages sent before the start_time" do
        expect(subject.unreceived_workstation_messages(start_time: 40.hours.ago, end_time: 10.hours.ago)).not_to include msg3
      end

      it "does not include messages sent after the end_time" do
        expect(subject.unreceived_workstation_messages(start_time: 40.hours.ago, end_time: 10.hours.ago)).not_to include msg4
      end

      it "does not include messages sent to the user's workstation(s) while the user was working at the workstation" do
        expect(subject.unreceived_workstation_messages).not_to include msg5
      end
    end
  end

  describe "#workstation_ids" do

    context "when the user is controlling one or more workstations" do

      before(:each) do
        subject.save
        cusn.set_user(subject)
        aml.set_user(subject)
      end

      it "returns a list of all the workstation id's under the control of the user" do
        subject.workstation_ids.should == [Workstation.find_by_abrev("CUSN").id, Workstation.find_by_abrev("AML").id]
      end
    end

    it "returns an empty list of the user has no workstations" do
      subject.workstation_ids.should == []
    end
  end
  
  describe "#workstation_names" do

    context "when the user is controlling one or more workstations" do

      before(:each) do
        subject.save
        cusn.set_user(subject)
        aml.set_user(subject)
      end

      it "returns a list of all of the user's workstation names" do
        subject.workstation_names.should == ["CUSN", "AML"]
      end
    end

    context "when the user is not controlling any workstations" do

      it "returns an empty list" do
        subject.workstation_names.should == []
      end
    end
  end

  describe "#workstation_names_str" do

    context "when the user is controlling one or more workstations" do

      before(:each) do
        subject.save
        cusn.set_user(subject)
        aml.set_user(subject)
      end

      it "returns a list of all of the user's workstation names as a string seperated by commas" do
        subject.workstation_names_str.should == "CUSN,AML"
      end
    end

    context "when the user is not controlling any workstations" do
      it "returns an empty string" do
        subject.workstation_names_str.should == ""
      end
    end
  end

  describe "#leave_workstation" do

    before(:each) do
      subject.save
      cusn.set_user(subject)
      aml.set_user(subject)
    end

    it "relinqishes control of all workstations belonging to the given user" do
      subject.leave_workstation
      Workstation.find_by_abrev("CUSN").user.should == nil
      Workstation.find_by_abrev("AML").user.should == nil
    end
  end

  describe "#add_recipients" do

    let(:workstations) { [cusn, aml] }
    before(:each) { subject.save }

    it "adds the list of workstations to the user's recipients" do
      subject.add_recipients(workstations)
      subject.recipients.size.should == workstations.size
      workstations.each do |workstation|
        subject.recipients.should include workstation
      end
    end

    it "doesn't add any duplicate recipients" do
      subject.add_recipients(workstations)
      subject.add_recipients(workstations)
      subject.recipients.size.should == 2
    end

    context "when the user is currently controlling a workstation" do
      before { aml.set_user(subject) }
      it "doesn't add the workstation as a recipient" do
        subject.add_recipients([aml])
        subject.should_not be_messaging aml.id
      end
    end

    it "returns an array of the recipients added" do
      message_routes = subject.add_recipients(workstations)
      message_routes.should == subject.message_routes
    end
  end

  describe "#add_recipient" do

    before(:each) { subject.save }

    it "adds the workstation to the user's recipients" do
      subject.add_recipient(aml)
      subject.recipients.should include aml
    end

    it "doesn't not add any duplicate recipients" do
      subject.add_recipient(aml)
      subject.add_recipient(aml)
      subject.recipients.size.should == 1
    end
    
    context "when the user is currently controlling a workstation" do
      before { aml.set_user(subject) }
      it "that workstation will not be added as a recipient" do
        subject.add_recipient(aml)
        subject.should_not be_messaging aml.id
      end
    end

    it "returns the newly created message_route" do
      message_route = subject.add_recipient(cusn)
      message_route.should == subject.message_routes[0]
    end
  end
  
  describe "#recipient_workstation_ids" do

    before(:each) do
      subject.save
      subject.add_recipient(cusn)
      subject.add_recipient(aml)
    end

    it "returns an array of the user's recipient's workstation_ids" do
      subject.recipient_workstation_ids.should == [cusn.id, aml.id]
    end
  end

  describe '#create_attached_message' do

    let(:attachment) { "test_file.txt" }
    let(:upload_file) { File.new(Rails.root + "spec/fixtures/files/" + attachment) }
    let(:payload) {{ payload: upload_file }}
    before(:each) { subject.save }

    it 'creates a message by the user with the given payload attached' do
      message = subject.create_attached_message(payload)
      expect(message.attachment.payload_identifier).to eq attachment
      expect(message.user_id).to eq subject.id
      expect(message.attachment.user_id).to eq subject.id
    end

    it 'creates a message with the attachment identifier as the content' do
      message = subject.create_attached_message(payload)
      expect(message.content).to eq attachment
    end
  end

  describe "#do_heartbeat" do

    let(:time) { Time.zone.now }
    before(:each) { subject.save }

    it "sets the heartbeat attribute to the given time" do
      subject.do_heartbeat(time)
      subject.heartbeat.should == time
    end
  end    

  describe "#set_online" do

    before(:each) { subject.save }

    it "sets the user's heartbeat time to the current time" do
      now = Time.zone.now
      Time.zone.stub(:now).and_return(now)
      subject.set_online
      subject.heartbeat.should == now
    end
  end

  describe "#set_offline" do

    before(:each) do
      subject.save
      subject.set_online
      cusn.set_user(subject)
      subject.add_recipient(aml)
      subject.set_offline
    end

    it "signs the user out of all workstations" do
      subject.reload
      subject.workstations.should == []
    end

    it "deletes all of the users recipients" do
      subject.reload
      subject.recipients.should == []
    end
  end

  describe "#messaging?" do
    
    before(:each) do
      subject.save
      FactoryGirl.create(:message_route, user: subject, workstation: cusn)
    end
    
    it "returns true if the given workstation is a recipient of the user" do
      subject.messaging?(cusn).should be_true
      subject.messaging?(aml).should be_false
    end
  end

  describe "#message_route_id" do

    before(:each) do
      subject.save
      @message_route = FactoryGirl.create(:message_route, user: subject, workstation: cusn)
    end
    
    it "returns the message_route_id associated with the given workstation_id" do
      subject.message_route_id(cusn).should == @message_route.id
    end
  end

  describe "#delete_all_message_routes" do
    
    before(:each) do
      subject.save
      FactoryGirl.create(:message_route, user: subject, workstation: cusn)
      FactoryGirl.create(:message_route, user: subject, workstation: aml)
    end

    it "deletes all of the user's recipients" do
      subject.recipients.size.should == 2
      subject.delete_all_message_routes
      subject.reload
      subject.recipients.should be_empty
    end
  end

  describe ".online" do
    
    let!(:online_user) { FactoryGirl.create(:user, user_name: "on", heartbeat: 14.seconds.ago) }
    let!(:offline_user) { FactoryGirl.create(:user, user_name: "off1", heartbeat: 15.seconds.ago) }
    let(:online_users) { User.online }

    before(:each) do
      subject.save
      subject.do_heartbeat(10.seconds.ago)
    end

    it "only returns online users" do
      online_users.should include subject
      online_users.should include online_user
      online_users.should_not include offline_user
    end
  end

  describe ".all_user_names" do
    let!(:user0) { FactoryGirl.create(:user, user_name: "jack") }
    let!(:user1) { FactoryGirl.create(:user, user_name: "jill") }

    it "returns a list of the user_names of all users in the system" do
      User.all_user_names.should include "jack"
      User.all_user_names.should include "jill"
    end
  end
end

