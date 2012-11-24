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
      user_with_same_name = FactoryGirl.create(:user, user_name: subject.user_name) 
    end
    it { should_not be_valid }
  end

  describe "when password is not present" do
    before { subject.password = subject.password_confirmation = " " }
    it { should_not be_valid }
  end

  describe "when password does not match confirmation" do
    before { subject.password_confirmation = "mismatch" }
    it { should_not be_valid }
  end

  describe "when password confirmation is nil" do
    before { subject.password_confirmation = nil }
    it { should_not be_valid }
  end

  describe "with a password that's too short" do
    before { subject.password = subject.password_confirmation = "a" * 5 }
    it { should_not be_valid }
  end 

  describe "with a password that's too long" do
    before { subject.password = subject.password_confirmation = "a" * 41 }
    it { should_not be_valid }
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

  describe "recipient associations" do

    before { subject.save }
    let!(:recipient1) { FactoryGirl.create(:recipient, user: subject) }
    let!(:recipient2) { FactoryGirl.create(:recipient, user: subject) }

    it { should respond_to(:recipients) }

    it "has the right recipients" do
      subject.recipients.should == [recipient1, recipient2]
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
          subject.recipients.map { |recipient| workstation.id }.should include workstation.id
        end
      end

      it "doesn't add any duplicate recipients" do
        subject.add_recipients(workstations)
        size1 = subject.recipients.size
        subject.add_recipients(workstations)
        size2 = subject.recipients.size
        size2.should == size1
      end

      context "when the user is currently controlling a workstation" do
        before { subject.start_job("AML") }
        it "doesn't add the workstation as a recipient" do
          subject.add_recipients([aml])
          subject.should_not be_messaging aml.id
        end
      end

      it "returns an array of the recipients added" do
        recipients = subject.add_recipients(workstations)
        recipients.should == subject.recipients
      end
    end

    describe "add_recipient" do

      it "adds the workstation id's to the user's recipients" do
        subject.add_recipient(ydmstr)
        subject.recipients[0].workstation_id.should == ydmstr.id
      end

      it "doesn't not add any duplicate recipients" do
        subject.add_recipient(ydmstr)
        size1 = subject.recipients.size
        subject.add_recipient(ydmstr)
        size2 = subject.recipients.size
        size2.should == size1
      end
      
      context "when the user is currently controlling a workstation" do
        before { subject.start_job("AML") }
        it "doesn't add the workstation as a recipient" do
          subject.add_recipient(aml)
          subject.should_not be_messaging aml.id
        end
      end

      it "returns the newly created recipient" do
        recipient = subject.add_recipient(ydmstr)
        recipient.should == subject.recipients[0]
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
        @recipient = FactoryGirl.create(:recipient, user: subject, workstation_id: cusn.id)
      end
      
      it "returns true if the given workstation is a recipient of the user" do
        subject.messaging?(cusn.id).should be_true
        subject.messaging?(cuss.id).should be_false
      end
    end

    describe "recipient_id" do

      before do
        @recipient = FactoryGirl.create(:recipient, user: subject, workstation_id: cusn.id)
      end
      
      it "returns the recipient_id associated with the given workstation_id" do
        subject.recipient_id(cusn.id).should eq(@recipient.id)
      end
    end

    describe "delete_all_recipients" do
      
      before do
        FactoryGirl.create(:recipient, user: subject, workstation_id: cusn.id)
        FactoryGirl.create(:recipient, user: subject, workstation_id: aml.id)
      end
      it "deletes all of the user's recipients" do
        subject.recipients.size.should == 2
        subject.delete_all_recipients
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

