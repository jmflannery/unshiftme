# == Schema Information
#
# Table name: users
#
#  id              :integer         not null, primary key
#  name            :string(255)
#  full_name       :string(255)
#  email           :string(255)
#  created_at      :datetime
#  updated_at      :datetime
#  password_digest :string(255)
#  recipient_id    :integer
#  heartbeat       :datetime
#

require 'spec_helper'

describe User do

  let!(:cusn) { FactoryGirl.create(:workstation, name: "CUS North", abrev: "CUSN", job_type: "td") }
  let(:cuss) { FactoryGirl.create(:workstation, name: "CUS South", abrev: "CUSS", job_type: "td") }
  let!(:aml) { FactoryGirl.create(:workstation, name: "AML / NOL", abrev: "AML", job_type: "td") }
  let(:ydctl) { FactoryGirl.create(:workstation, name: "Yard Control", abrev: "YDCTL", job_type: "ops") }
  let(:ydmstr) { FactoryGirl.create(:workstation, name: "Yard Master", abrev: "YDMSTR", job_type: "ops") }
  let(:glhs) { FactoryGirl.create(:workstation, name: "Glasshouse", abrev: "GLHS", job_type: "ops") }

  before(:each) do
    @user = User.new(
      user_name: "smith",
      password: "foobar",
      password_confirmation: "foobar",
      normal_workstations: %w(CUSN CUSS)
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

  describe "the first user to be created" do
    before do subject.save end
    it "is an admin by default" do
      subject.should be_admin
    end
  end

  describe "subsequently created users" do
    before do 
      subject.save
      @second_user = FactoryGirl.create(:user)
    end
    it "are non-admin by default" do
      @second_user.should_not be_admin
    end
  end

  describe "when user_name is not present" do
    before { subject.user_name = " " }
    it { should_not be_valid }
  end

  describe "when user_name is already taken" do
    before do
      FactoryGirl.create(:user, user_name: subject.user_name) 
    end
    it { should_not be_valid }
  end

  describe "password validation" do
    
    context "on new record" do

      context "when password is not present" do
        before { subject.password = subject.password_confirmation = " " }
        it "user is invalid" do
          subject.should_not be_valid
        end
      end

      context "when password does not match confirmation" do
        before { subject.password_confirmation = "mismatch" }
        it "user is invalid" do
          subject.should_not be_valid
        end
      end

      context "when password confirmation is nil" do
        before { subject.password_confirmation = nil }
        it "user is invalid" do
          subject.should_not be_valid
        end
      end

      context "with a password that's too short" do
        before { subject.password = subject.password_confirmation = "a" * 5 }
        it "user is invalid" do
          subject.should_not be_valid
        end
      end 

      context "with a password that's too long" do
        before { subject.password = subject.password_confirmation = "a" * 41 }
        it "user is invalid" do
          subject.should_not be_valid
        end
      end 
    end

    context "on an existing record" do
      before { subject.save }

      context "when updating the password" do
        before { subject.updating_password! }

        context "when password is not present" do
          before { subject.password = subject.password_confirmation = " " }
          it "user is invalid" do
            should_not be_valid
          end
        end
      end

      context "when not updating the password" do

        context "when password is not present" do
          before { subject.password = subject.password_confirmation = " " }
          it "no validation on password will occur and user is valid" do
            subject.should be_valid
          end
        end
      end
    end
  end

  describe "return value of authenticate method" do
    before { subject.save }
    let(:found_user) { User.find_by_user_name(subject.user_name) } 

    context "with valid password" do
      it { should == found_user.authenticate(subject.password) }
    end

    context "with an invalid password" do
      let(:user_with_invalid_password) { found_user.authenticate("invalid") }
      
      it { should_not == user_with_invalid_password } 
      specify { user_with_invalid_password.should be_false }
    end
  end

  describe "workstation associations" do
    it { should have_many(:workstations) }
  end
  
  describe "message associations" do

    before { subject.save }
    let!(:older_message) { FactoryGirl.create(:message, user: subject, created_at: 1.day.ago) }
    let!(:newer_message) { FactoryGirl.create(:message, user: subject, created_at: 1.minute.ago) }

    it { should respond_to(:messages) }

    it "has the right messages in the right order" do
      subject.messages.should == [newer_message, older_message]
    end
  end

  describe "message_routes/recipients association" do

    before { subject.save }
    let!(:message_route) { subject.message_routes.create(workstation: cusn) }

    it "should have many message_routes" do
      subject.should have_many :message_routes
    end

    it "should have many recipients" do
      subject.should have_many :recipients
    end

    it "should have a list of recipients" do
      subject.recipients.should include cusn
      message_route.user_id.should == subject.id
    end
  end

  describe "incoming_receipts/incoming_messages association" do

    before { subject.save }
    let(:message) { FactoryGirl.create(:message) }
    let!(:incoming_receipt) { subject.incoming_receipts.create(message: message) }

    it "should have many incoming_receipts" do
      subject.should have_many :incoming_receipts
    end

    it "should have many incoming_messages" do
      subject.should have_many :incoming_messages
    end

    it "should have a list of incoming_messages" do
      subject.incoming_messages.should include message
      incoming_receipt.message_id.should == subject.id
    end
  end

  describe "outgoing_receipts/sent_messages association" do

    before { subject.save }
    let(:message) { FactoryGirl.create(:message) }
    let!(:outgoing_receipt) { subject.outgoing_receipts.create(message: message) }

    it "should have many outgoing_receipts" do
      subject.should have_many :outgoing_receipts
    end

    it "should have many outgoing_messages" do
      subject.should have_many :outgoing_messages
    end

    it "should have a list of outging_messages" do
      subject.outgoing_messages.should include message
      outgoing_receipt.message_id.should == subject.id
    end
  end

  describe "acknowledgements/read_messages association" do

    let(:message) { FactoryGirl.create(:message) }
    let(:acknowledgement) { Acknowledgement.create(message: message) }
    before {
      subject.acknowledgements << acknowledgement
      subject.save
    }

    it { should have_many :acknowledgements }
    it { should have_many :read_messages }

    it "should have a list of messages read" do
      subject.read_messages.should include message
      acknowledgement.user_id.should == subject.id
    end
  end

  describe "workstation associations" do

    before(:each) do
      subject.normal_workstations = [cusn.abrev, cuss.abrev]
    end

    it { should respond_to(:normal_workstations) }

    it "has the right workstations" do
      subject.normal_workstations.should == [cusn.abrev, cuss.abrev]
    end
  end
  
  describe "attachment associations" do

    before { subject.save }
    let!(:attachment1) { FactoryGirl.create(:attachment, user: subject) }
    let!(:attachment2) { FactoryGirl.create(:attachment, user: subject) }

    it { should respond_to(:attachments) }

    it "has the right attachements" do
      subject.attachments.should == [attachment1, attachment2]
    end
  end
  
  describe "transcript associations" do

    before { subject.save }
    let!(:transcript1) { FactoryGirl.create(:transcript, user: subject, transcript_user_id: 11, start_time: 1.hour.ago, end_time: 1.minute.ago) }
    let!(:transcript2) { FactoryGirl.create(:transcript, user: subject, transcript_user_id: 22, start_time: 3.hours.ago, end_time: 4.hours.ago) }

    it { should respond_to(:transcripts) }

    it "has the right transcripts in descending order" do
      subject.transcripts.should == [transcript2, transcript1]
    end
  end

  describe "method" do
    
    before(:each) do
      subject.save
    end

    describe "updating_password?" do

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

    describe "updating_password!" do
      
      it "sets updating_password to true" do
        subject.should_not be_updating_password
        subject.updating_password!
        subject.should be_updating_password
      end
    end
    
    describe "handle" do

      before do
        subject.start_jobs(["CUSN", "AML"])
      end

      it "returns a string in the format user_name@workstation,workstation" do
        subject.handle.should == "smith@CUSN,AML"
      end
    end

    describe "#as_json" do
      
      let(:user1) { FactoryGirl.create(:user, user_name: "Jimbo") }
      before(:each) do
        @user.start_jobs([cusn.abrev, aml.abrev])
        user1.start_job(cuss.abrev)
        recipient = @user.add_recipient(cuss)
        @expected = { id: @user.id,
                      user_name: "smith",
                      workstations: [{name: "CUSN"}, {name: "AML"}],
                      recipient_workstations: [{ name: "CUSS", recipient_id: recipient.id }]
        }.to_json
      end

      it "returns the user's info as json" do
        @user.as_json.should == @expected
      end
    end

    describe "#display_messages" do

      let(:sender) { FactoryGirl.create(:user) }

      it "returns messages that were sent by the given user" do
        msg = subject.messages.create(content: "this is a message")
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

      let(:sender) { FactoryGirl.create(:user) }

      it "returns messages sent to the user's workstations while those workstations had no user" do
        sender.add_recipient(cusn)
        msg = sender.messages.create(content: "this is a message")
        msg.generate_incoming_receipts
        cusn.set_user(subject)
        subject.unreceived_workstation_messages.should include msg
      end

      it "does not return messages sent to the user's workstations while those workstations had a user" do
        sender.add_recipient(cusn)
        msg = sender.messages.create(content: "this is a message")
        cusn.set_user(subject)
        msg.generate_incoming_receipts
        subject.unreceived_workstation_messages.should_not include msg
      end
    
      it "returns an empty array if the user has no workstations" do
        sender.add_recipient(cusn)
        msg = sender.messages.create(content: "this is a message")
        msg.generate_incoming_receipts
        subject.unreceived_workstation_messages.should == []
      end

      it "does not return messages older than 24 hours" do
        sender.add_recipient(cusn)
        msg = sender.messages.create(content: "this is a message")
        msg.update_attribute(:created_at, 25.hours.ago)
        msg.generate_incoming_receipts
        cusn.set_user(subject)
        subject.unreceived_workstation_messages.should_not include msg
      end
      
      context "if the start_time option parameter is supplied" do

        it "does not return messages sent before the supplied start_time" do
          sender.add_recipient(cusn)
          msg = sender.messages.create(content: "this is a message")
          msg.update_attribute(:created_at, 13.hours.ago)
          msg.generate_incoming_receipts
          cusn.set_user(subject)
          subject.unreceived_workstation_messages(start_time: 12.hours.ago).should_not include msg
        end
      end

      context "if the end_time option parameter is supplied" do

        it "does not return messages sent after the supplied end_time" do
          sender.add_recipient(cusn)
          msg = sender.messages.create(content: "this is a message")
          msg.update_attribute(:created_at, 13.hours.ago)
          msg.generate_incoming_receipts
          cusn.set_user(subject)
          subject.unreceived_workstation_messages(end_time: 14.hours.ago).should_not include msg
        end
      end

      context "if the start_time and end_time option parameters are supplied" do

        it "does not return messages sent after the supplied end_time" do
          sender.add_recipient(cusn)
          msg = sender.messages.create(content: "this is a message")
          msg.update_attribute(:created_at, 33.hours.ago)
          msg2 = sender.messages.create(content: "this is a message")
          msg2.update_attribute(:created_at, 1.hours.ago)
          msg.generate_incoming_receipts
          cusn.set_user(subject)
          subject.unreceived_workstation_messages(start_time: 32.hours.ago, end_time: 2.hours.ago).should_not include msg
          subject.unreceived_workstation_messages(start_time: 32.hours.ago, end_time: 2.hours.ago).should_not include msg2
        end
      end
    end
    
    describe "start_jobs" do
    
      it "assignes the jobs to the user" do
        subject.start_jobs([cusn.abrev, aml.abrev])
        Workstation.find_by_abrev("CUSN").user_id.should == subject.id  
        Workstation.find_by_abrev("AML").user_id.should == subject.id  
      end
    end

    describe "start_job" do

      it "assignes the job to the user" do
        subject.start_job(cusn.abrev)
        Workstation.find_by_abrev("CUSN").user_id.should == subject.id  
      end
    end

    describe "workstation_ids" do

      context "when the user is controlling one or more workstations (by calling start_job or start_jobs)" do
        before { subject.start_jobs(["CUSN", "AML"]) }
        it "returns a list of all the workstation id's under the control of the user" do
          subject.workstation_ids.should == [Workstation.find_by_abrev("CUSN").id, Workstation.find_by_abrev("AML").id]
        end
      end

      it "returns an empty list of the user has no workstations" do
        subject.workstation_ids.should == []
      end
    end
    
    describe "workstation_names" do

      context "when the user is controlling one or more workstations (by calling start_job or start_jobs)" do
        before { subject.start_jobs(["CUSN", "AML"]) }
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

    describe "workstation_names_str" do

      context "when the user is controlling one or more workstations (by calling start_job or start_jobs)" do
        before { subject.start_jobs(["CUSN", "AML"]) }
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

    describe "leave_workstation" do

      before(:each) { subject.start_jobs(["CUSN", "AML"]) }

      it "relinqishes control of all workstations belonging to the given user" do
        subject.leave_workstation
        Workstation.find_by_abrev("CUSN").user.should == nil
        Workstation.find_by_abrev("AML").user.should == nil
      end
    end

    describe "add_recipients" do

      let(:workstations) { [cusn, cuss] }

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

    describe "add_recipient" do

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
        message_route = subject.add_recipient(ydmstr)
        message_route.should == subject.message_routes[0]
      end
    end
    
    describe "recipient_workstation_ids" do

      before(:each) do
        subject.add_recipient(ydmstr)
        subject.add_recipient(glhs)
      end

      it "returns an array of the user's recipient's workstation_ids" do
        subject.recipient_workstation_ids.should == [ydmstr.id, glhs.id]
      end
    end

    describe "#do_heartbeat" do
      let(:time) { Time.zone.now }

      it "sets the heartbeat attribute to the given time" do
        subject.do_heartbeat(time)
        subject.heartbeat.should == time
      end
    end    

    describe "set_online" do

      before(:each) do
        @time = Time.now
        subject.set_online
      end

      it "sets the user's heartbeat time to the current time" do
        subject.reload.heartbeat.should > @time
      end
    end

    describe "set_offline" do

      before do 
        subject.set_online
        subject.start_job(cusn.abrev)
        subject.add_recipient(cuss)
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

    describe "messaging?" do
      
      before do 
        FactoryGirl.create(:message_route, user: subject, workstation: cusn)
      end
      
      it "returns true if the given workstation is a recipient of the user" do
        subject.messaging?(cusn).should be_true
        subject.messaging?(cuss).should be_false
      end
    end

    describe "message_route_id" do

      before do
        @message_route = FactoryGirl.create(:message_route, user: subject, workstation: cusn)
      end
      
      it "returns the message_route_id associated with the given workstation_id" do
        subject.message_route_id(cusn).should == @message_route.id
      end
    end

    describe "delete_all_message_routes" do
      
      before do
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
  end

  describe "class method" do

    describe "online" do
      
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

    describe "all_user_names" do
      let!(:user0) { FactoryGirl.create(:user, user_name: "jack") }
      let!(:user1) { FactoryGirl.create(:user, user_name: "jill") }

      it "returns a list of the user_names of all users in the system" do
        User.all_user_names.should include "jack"
        User.all_user_names.should include "jill"
      end
    end
  end
end

