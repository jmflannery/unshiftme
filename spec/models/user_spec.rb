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
#  status          :boolean
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
    @user = User.new(user_name: "smith", password: "foobar", password_confirmation: "foobar")
  end

  subject { @user }

  it { should respond_to(:user_name) }
  it { should respond_to(:password) }
  it { should respond_to(:password_confirmation) }
  it { should respond_to(:admin) }
  it { should respond_to(:authenticate) }

  it { should be_valid }

  describe "with admin attribute set to true" do
    before { subject.toggle!(:admin) }

    it { should be_admin }
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

  describe "return value of authenticate method" do
    before { subject.save }
    let(:found_user) { User.find_by_user_name(subject.user_name) } 

    describe "with valid password" do
      it { should == found_user.authenticate(subject.password) }
    end

    describe "with an invalid password" do
      let(:user_with_invalid_password) { found_user.authenticate("invalid") }
      
      it { should_not == user_with_invalid_password } 
      specify { user_with_invalid_password.should be_false }
    end
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

  describe "scope" do
    
    describe "online" do
      
      before(:each) do
        subject.save
        @user1 = FactoryGirl.create(:user, status: true)
      end
      let(:online_users) { User.online }
  
      it "only returns online users" do
        online_users.should include @user1
        online_users.should_not include subject
      end
    end
  end

  describe "method" do
    
    before(:each) do
      subject.save
    end
    
    describe "handle" do

      before do
        #FactoryGirl.create(:workstation, name: "CUS North", abrev: "CUSN", job_type: "td")
        #FactoryGirl.create(:workstation, name: "AML / NOL", abrev: "AML", job_type: "td")
        subject.authenticate_workstation("CUSN" => 1, "AML" => 1)
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
        @user.add_recipient(cuss)
        @expected = { id: @user.id,
                      user_name: "smith",
                      workstations: [{name: "CUSN"}, {name: "AML"}],
                      recipient_workstations: [{name: "CUSS"}]
        }.to_json
      end

      it "returns the user's info as json" do
        @user.as_json.should == @expected
      end
    end

    describe "Workstation" do
      
      before(:each) do
        @params = { key: "val", "CUSN" => 1, "AML" => 1, anotherkey: "val" }
      end

      describe "authenticate_workstation" do
        
        it "parses the user params and assiges control of each workstation to the user" do
          subject.authenticate_workstation(@params)
          Workstation.find_by_abrev("CUSN").user_id.should == subject.id  
          Workstation.find_by_abrev("AML").user_id.should == subject.id  
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

        before(:each) do
          subject.authenticate_workstation(@params)
        end

        it "returns a list of all the workstation id's under the control of the user" do
          subject.workstation_ids.should be_kind_of Array
          subject.workstation_ids.should == [Workstation.find_by_abrev("CUSN").id, Workstation.find_by_abrev("AML").id]
        end

        it "returns an empty list of the user has no workstations" do
          @user2 = FactoryGirl.build(:user)
          @user2.workstation_ids.should == []
        end
      end
      
      describe "workstation_names" do

        before(:each) do
          subject.authenticate_workstation(@params)
        end

        it "returns a list of all the workstation abreviation names under the control of the user" do
          subject.workstation_names.should == [Workstation.find_by_abrev("CUSN").abrev, Workstation.find_by_abrev("AML").abrev]
        end

        it "returns an empty list of the user has no workstations" do
          @user2 = FactoryGirl.build(:user)
          @user2.workstation_names.should == []
        end
      end

      describe "workstation_names_str" do

        before(:each) do
          subject.authenticate_workstation(@params)
        end

        it "returns a list of all the workstation abreviation names under the control of the user as a string seperated by commas" do
          subject.workstation_names_str.should == "#{Workstation.find_by_abrev("CUSN").abrev},#{Workstation.find_by_abrev("AML").abrev}"
        end

        it "returns an empty string of the user has no workstations" do
          @user2 = FactoryGirl.build(:user)
          @user2.workstation_names_str.should == ""
        end
      end

      describe "leave_workstation" do

        before(:each) do
          subject.authenticate_workstation(@params)
        end

        it "relinqishes control of all workstations belonging to the given user" do
          subject.leave_workstation
          Workstation.find_by_abrev("CUSN").user_id.should == 0
          Workstation.find_by_abrev("AML").user_id.should == 0
        end
      end
    end

    describe "add_recipients" do

      before(:each) do
        @workstation_ids = [cusn, cuss]
        @recipients = subject.add_recipients(@workstation_ids)
      end

      it "adds the list of workstations to the user's recipients" do
        subject.recipients.size.should == @workstation_ids.size
        subject.recipients.each do |recipient|
          @workstation_ids.map { |d| d.id }.should include recipient.workstation_id
        end
      end

      it "doesn't add any duplicate recipients" do
        size1 = subject.recipients.size
        subject.add_recipients(@workstation_ids)
        size2 = subject.recipients.size
        size2.should == size1
      end

      it "doesn't add a workstation as a recipient if the user is currently controlling that workstation" do
        subject.authenticate_workstation(aml.abrev => 1)
        @workstation_ids << aml
        subject.add_recipients(@workstation_ids)
        subject.should_not be_messaging aml.id
      end

      it "returns an array of the recipients added" do
        @recipients.should == subject.recipients
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
      
      it "doesn't add a workstation as a recipient if the user is currently controlling that workstation" do
        subject.authenticate_workstation(ydmstr.abrev => 1)
        subject.add_recipient(ydmstr)
        subject.should_not be_messaging ydmstr.id
      end

      it "returns the newly created recipient" do
        recipient_id = subject.add_recipient(ydmstr)
        recipient_id.should == subject.recipients[0]
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
      
      it "set the heartbeart to the current time" do
        time = Time.now
        subject.do_heartbeat
        subject.heartbeat.should > time
      end
    end

    describe "#set_heartbeat" do
      let(:time) { Time.now }

      it "sets the heartbeat attribute to the given time" do
        subject.set_heartbeat(time)
        subject.heartbeat.should == time
      end
    end    

    describe "set_online" do

      before(:each) do
        @time = Time.now
        subject.set_online
      end

      it "sets the user's online status to true" do
        subject.reload
        subject.status.should be_true
      end

      it "sets the user's heartbeat time to the current time" do
        subject.reload
        subject.heartbeat.should > @time
      end
    end

    describe "set_offline" do

      before do 
        subject.set_online
        subject.start_job(cusn.abrev)
        subject.add_recipient(cuss)
        subject.set_offline
      end

      it "sets the user's online status to false" do
        subject.status.should be_false
      end

      it "signs the user out of all workstations" do
        subject.workstation_ids.should == []
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

    describe "#sign_out_the_dead" do
      
      let(:user1) { FactoryGirl.create(:user, user_name: "Jimbo") }

      context "for users who have not had a heartbeat in over 30 seconds" do

        before(:each) do
          subject.save
          subject.set_online
          @recipient = subject.add_recipient(cuss)
          subject.start_job(cusn.abrev)
          subject.update_attribute(:heartbeat, 29.seconds.ago)
          user1.set_online
          user1.add_recipient(cusn)
          user1.start_job(aml.abrev)
          user1.update_attribute(:heartbeat, 35.seconds.ago)
          User.sign_out_the_dead
          subject.reload
          user1.reload
        end

        it "sets online status to false" do
          subject.status.should be_true
          user1.status.should_not be_true
        end

        it "signs the user out of all workstations" do
          user1.workstation_ids.should == []
          subject.workstation_ids.should == [cusn.id]
        end

        it "destroys all of the user's recipients" do
          user1.recipients.should == []
          subject.recipients.should == [@recipient]
        end
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

