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

  let!(:cusn) { FactoryGirl.create(:desk, name: "CUS North", abrev: "CUSN", job_type: "td") }
  let(:cuss) { FactoryGirl.create(:desk, name: "CUS South", abrev: "CUSS", job_type: "td") }
  let!(:aml) { FactoryGirl.create(:desk, name: "AML / NOL", abrev: "AML", job_type: "td") }
  let(:ydctl) { FactoryGirl.create(:desk, name: "Yard Control", abrev: "YDCTL", job_type: "ops") }
  let(:ydmstr) { FactoryGirl.create(:desk, name: "Yard Master", abrev: "YDMSTR", job_type: "ops") }
  let(:glhs) { FactoryGirl.create(:desk, name: "Glasshouse", abrev: "GLHS", job_type: "ops") }

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

  describe "desk associations" do

    before(:each) do
      subject.normal_desks = [cusn.abrev, cuss.abrev]
    end

    it { should respond_to(:normal_desks) }

    it "has the right desks" do
      subject.normal_desks.should == [cusn.abrev, cuss.abrev]
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
    let!(:transcript1) { FactoryGirl.create(:transcript, user: subject, watch_user_id: 11, start_time: 1.hour.ago, end_time: 1.minute.ago) }
    let!(:transcript2) { FactoryGirl.create(:transcript, user: subject, watch_user_id: 22, start_time: 3.hours.ago, end_time: 4.hours.ago) }

    it { should respond_to(:transcripts) }

    it "has the right transcripts" do
      subject.transcripts.should == [transcript1, transcript2]
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
        #FactoryGirl.create(:desk, name: "CUS North", abrev: "CUSN", job_type: "td")
        #FactoryGirl.create(:desk, name: "AML / NOL", abrev: "AML", job_type: "td")
        subject.authenticate_desk("CUSN" => 1, "AML" => 1)
      end

      it "returns a string in the format user_name@desk,desk" do
        subject.handle.should == "smith@CUSN,AML"
      end
    end

    describe "Desk" do
      
      before(:each) do
        @params = { key: "val", "CUSN" => 1, "AML" => 1, anotherkey: "val" }
        #FactoryGirl.create(:desk, name: "CUS North", abrev: "CUSN", job_type: "td")
        #FactoryGirl.create(:desk, name: "AML / NOL", abrev: "AML", job_type: "td")
      end

      describe "authenticate_desk" do
        
        it "parses the user params and assiges control of each desk to the user" do
          subject.authenticate_desk(@params)
          Desk.find_by_abrev("CUSN").user_id.should == subject.id  
          Desk.find_by_abrev("AML").user_id.should == subject.id  
        end
      end

      describe "start_jobs" do
      
        it "assignes the jobs to the user" do
          subject.start_jobs([cusn.abrev, aml.abrev])
          Desk.find_by_abrev("CUSN").user_id.should == subject.id  
          Desk.find_by_abrev("AML").user_id.should == subject.id  
        end
      end

      describe "start_job" do

        it "assignes the job to the user" do
          subject.start_job(cusn.abrev)
          Desk.find_by_abrev("CUSN").user_id.should == subject.id  
        end
      end

      describe "desks" do

        before(:each) do
          subject.authenticate_desk(@params)
        end

        it "returns a list of all the desk id's under the control of the user" do
          subject.desks.should be_kind_of Array
          subject.desks.should == [Desk.find_by_abrev("CUSN").id, Desk.find_by_abrev("AML").id]
        end

        it "returns an empty list of the user has no desks" do
          @user2 = FactoryGirl.build(:user)
          @user2.desks.should == []
        end
      end
      
      describe "desk_names" do

        before(:each) do
          subject.authenticate_desk(@params)
        end

        it "returns a list of all the desk abreviation names under the control of the user" do
          subject.desk_names.should == [Desk.find_by_abrev("CUSN").abrev, Desk.find_by_abrev("AML").abrev]
        end

        it "returns an empty list of the user has no desks" do
          @user2 = FactoryGirl.build(:user)
          @user2.desk_names.should == []
        end
      end

      describe "desk_names_str" do

        before(:each) do
          subject.authenticate_desk(@params)
        end

        it "returns a list of all the desk abreviation names under the control of the user as a string seperated by commas" do
          subject.desk_names_str.should == "#{Desk.find_by_abrev("CUSN").abrev},#{Desk.find_by_abrev("AML").abrev}"
        end

        it "returns an empty string of the user has no desks" do
          @user2 = FactoryGirl.build(:user)
          @user2.desk_names_str.should == ""
        end
      end

      describe "leave_desk" do

        before(:each) do
          subject.authenticate_desk(@params)
        end

        it "relinqishes control of all desks belonging to the given user" do
          subject.leave_desk
          Desk.find_by_abrev("CUSN").user_id.should == 0
          Desk.find_by_abrev("AML").user_id.should == 0
        end
      end
    end

    describe "add_recipients" do

      before(:each) do
        @desks = [cusn, cuss]
        @recipients = subject.add_recipients(@desks)
      end

      it "adds the list of desks to the user's recipients" do
        subject.recipients.size.should == @desks.size
        subject.recipients.each do |recipient|
          @desks.map { |d| d.id }.should include recipient.desk_id
        end
      end

      it "doesn't add any duplicate recipients" do
        size1 = subject.recipients.size
        subject.add_recipients(@desks)
        size2 = subject.recipients.size
        size2.should == size1
      end

      it "doesn't add a desk as a recipient if the user is currently controlling that desk" do
        subject.authenticate_desk(aml.abrev => 1)
        @desks << aml
        subject.add_recipients(@desks)
        subject.should_not be_messaging aml.id
      end

      it "returns an array of the recipients added" do
        @recipients.should == subject.recipients
      end
    end

    describe "add_recipient" do

      #before(:each) do
      #  @ydmstr = FactoryGirl.create(:desk, name: "Yard Master", abrev: "YDMSTR", job_type: "ops")
      #end

      it "adds the desk id's to the user's recipients" do
        subject.add_recipient(ydmstr)
        subject.recipients[0].desk_id.should == ydmstr.id
      end

      it "doesn't not add any duplicate recipients" do
        subject.add_recipient(ydmstr)
        size1 = subject.recipients.size
        subject.add_recipient(ydmstr)
        size2 = subject.recipients.size
        size2.should == size1
      end
      
      it "doesn't add a desk as a recipient if the user is currently controlling that desk" do
        subject.authenticate_desk(ydmstr.abrev => 1)
        subject.add_recipient(ydmstr)
        subject.should_not be_messaging ydmstr.id
      end
    end
    
    describe "recipient_desk_ids" do

      before(:each) do
        subject.add_recipient(ydmstr)
        subject.add_recipient(glhs)
      end

      it "returns an array of the user's recipient's desk_ids" do
        subject.recipient_desk_ids.should == [ydmstr.id, glhs.id]
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

      it "signs the user out of all desks" do
        subject.desks.should == []
      end

      it "deletes all of the users recipients" do
        subject.reload
        subject.recipients.should == []
      end
    end

    describe "messaging?" do
      
      before do 
        @recipient = FactoryGirl.create(:recipient, user: subject, desk_id: cusn.id)
      end
      
      it "returns true if the given desk is a recipient of the user" do
        subject.messaging?(cusn.id).should be_true
        subject.messaging?(cuss.id).should be_false
      end
    end

    describe "recipient_id" do

      before do
        @recipient = FactoryGirl.create(:recipient, user: subject, desk_id: cusn.id)
      end
      
      it "returns the recipient_id associated with the given desk_id" do
        subject.recipient_id(cusn.id).should eq(@recipient.id)
      end
    end

    describe "delete_all_recipients" do
      
      before do
        FactoryGirl.create(:recipient, user: subject, desk_id: cusn.id)
        FactoryGirl.create(:recipient, user: subject, desk_id: aml.id)
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

      context "for users who have not had a heartbeat in over 60 seconds" do

        before(:each) do
          subject.save
          subject.set_online
          @recipient = subject.add_recipient(cuss)
          subject.start_job(cusn.abrev)
          subject.update_attribute(:heartbeat, 19.seconds.ago)
          user1.set_online
          user1.add_recipient(cusn)
          user1.start_job(aml.abrev)
          user1.update_attribute(:heartbeat, 25.seconds.ago)
          User.sign_out_the_dead
          subject.reload
          user1.reload
        end

        it "sets online status to false" do
          subject.status.should be_true
          user1.status.should_not be_true
        end

        it "signs the user out of all desks" do
          user1.desks.should == []
          subject.desks.should == [cusn.id]
        end

        it "destroys all of the user's recipients" do
          user1.recipients.should == []
          subject.recipients.should == [@recipient]
        end
      end
    end
  end
end

