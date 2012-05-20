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
#  lastpoll        :datetime
#

require 'spec_helper'

describe User do

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
    before { @user.toggle!(:admin) }

    it { should be_admin }
  end

  describe "when user_name is not present" do
    before { @user.user_name = " " }
    it { should_not be_valid }
  end

  describe "when user_name is already taken" do
    before do
      user_with_same_name = FactoryGirl.create(:user, user_name: @user.user_name) 
    end

    it { should_not be_valid }
  end

  describe "when password is not present" do
    before { @user.password = @user.password_confirmation = " " }
    it { should_not be_valid }
  end

  describe "when password does not match confirmation" do
    before { @user.password_confirmation = "mismatch" }
    it { should_not be_valid }
  end

  describe "when password confirmation is nil" do
    before { @user.password_confirmation = nil }
    it { should_not be_valid }
  end

  describe "with a password that's too short" do
    before { @user.password = @user.password_confirmation = "a" * 5 }
    it { should_not be_valid }
  end 

  describe "return value of authenticate method" do
    before { @user.save }
    let(:found_user) { User.find_by_user_name(@user.user_name) } 

    describe "with valid password" do
      it { should == found_user.authenticate(@user.password) }
    end

    describe "with an invalid password" do
      let(:user_with_invalid_password) { found_user.authenticate("invalid") }
      
      it { should_not == user_with_invalid_password } 
      specify { user_with_invalid_password.should be_false }
    end
  end
  
  describe "message associations" do

    before { @user.save }
    let!(:older_message) do
      FactoryGirl.create(:message, user: @user, created_at: 1.day.ago)
    end
    let!(:newer_message) do
      FactoryGirl.create(:message, user: @user, created_at: 1.minute.ago)
    end

    it { should respond_to(:messages) }

    it "has the right messages in the right order" do
      @user.messages.should == [newer_message, older_message]
    end
  end

  describe "recipient associations" do

    before { @user.save }
    let!(:recipient1) do
      FactoryGirl.create(:recipient, user: @user)
    end
    let!(:recipient2) do
      FactoryGirl.create(:recipient, user: @user)
    end

    it { should respond_to(:recipients) }

    it "has the right recipients" do
      @user.recipients.should == [recipient1, recipient2]
    end
  end

  describe "attachment associations" do

    before { @user.save }
    let!(:attachment1) do
      FactoryGirl.create(:attachment, user: @user)
    end
    let!(:attachment2) do
      FactoryGirl.create(:attachment, user: @user)
    end

    it { should respond_to(:attachments) }

    it "has the right attachements" do
      @user.attachments.should == [attachment1, attachment2]
    end
  end
  
  describe "transcript associations" do

    before { @user.save }
    let!(:transcript1) do
      FactoryGirl.create(:transcript, user: @user, watch_user_id: 11, start_time: 1.hour.ago, end_time: 1.minute.ago)
    end
    let!(:transcript2) do
      FactoryGirl.create(:transcript, user: @user, watch_user_id: 22, start_time: 3.hours.ago, end_time: 4.hours.ago)
    end

    it { should respond_to(:transcripts) }

    it "has the right transcripts" do
      @user.transcripts.should == [transcript1, transcript2]
    end
  end

  describe "scope" do
    
    describe "online" do
      
      before(:each) do
        @user.save
        @user1 = FactoryGirl.create(:user, status: true)
      end
      let(:online_users) { User.online }
  
      it "only returns online users" do
        online_users.should include @user1
        online_users.should_not include @user
      end

    end
  end

  describe "method" do
    
    before(:each) do
      @user.save
    end

    describe "Desk" do
      
      before(:each) do
        @params = { key: "val", "CUSN" => 1, "AML" => 1, anotherkey: "val" }
        Desk.create!(name: "CUS North", abrev: "CUSN", job_type: "td")
        Desk.create!(name: "AML / NOL", abrev: "AML", job_type: "td")
      end

      describe "authenticate_desk" do
        
        it "parses the user params and assiges control of each desk to the user" do
          @user.authenticate_desk(@params)
          Desk.find_by_abrev("CUSN").user_id.should == @user.id  
          Desk.find_by_abrev("AML").user_id.should == @user.id  
        end
      end

      describe "desks" do

        before(:each) do
          @user.authenticate_desk(@params)
        end

        it "returns a list of all the desk id's under the control of the user" do
          @user.desks.should be_kind_of Array
          @user.desks.should == [Desk.find_by_abrev("CUSN").id, Desk.find_by_abrev("AML").id]
        end

        it "returns an empty list of the user has no desks" do
          @user2 = FactoryGirl.build(:user)
          @user2.desks.should == []
        end
      end
      
      describe "desk_names" do

        before(:each) do
          @user.authenticate_desk(@params)
        end

        it "returns a list of all the desk abreviation names under the control of the user" do
          @user.desk_names.should == [Desk.find_by_abrev("CUSN").abrev, Desk.find_by_abrev("AML").abrev]
        end

        it "returns an empty list of the user has no desks" do
          @user2 = FactoryGirl.build(:user)
          @user2.desk_names.should == []
        end
      end

      describe "desk_names_str" do

        before(:each) do
          @user.authenticate_desk(@params)
        end

        it "returns a list of all the desk abreviation names under the control of the user as a string seperated by commas" do
          @user.desk_names_str.should == "#{Desk.find_by_abrev("CUSN").abrev},#{Desk.find_by_abrev("AML").abrev}"
        end

        it "returns an empty string of the user has no desks" do
          @user2 = FactoryGirl.build(:user)
          @user2.desk_names_str.should == ""
        end
      end

      describe "leave_desk" do

        before(:each) do
          @user.authenticate_desk(@params)
        end

        it "relinqishes control of all desks belonging to the given user" do
          @user.leave_desk
          Desk.find_by_abrev("CUSN").user_id.should_not == @user.id  
          Desk.find_by_abrev("AML").user_id.should_not == @user.id  
        end
      end
    end

    describe "add_recipients" do

      before(:each) do
        @cusn = Desk.create!(name: "CUS North", abrev: "CUSN", job_type: "td")
        @cuss = Desk.create!(name: "CUS South", abrev: "CUSS", job_type: "td")
        @desks = [@cusn, @cuss]
        @user.add_recipients(@desks)
      end

      it "adds the list of desks to the user's recipients" do
        @user.recipients.size.should == @desks.size
        @user.recipients.each do |recipient|
          @desks.map { |d| d.id }.should include recipient.desk_id
        end
      end

      it "doesn't add any duplicate recipients" do
        size1 = @user.recipients.size
        @user.add_recipients(@desks)
        size2 = @user.recipients.size
        size2.should == size1
      end
    end

    describe "add_recipient" do

      before(:each) do
        @ydmstr = Desk.create!(name: "Yard Master", abrev: "YDMSTR", job_type: "ops")
      end

      it "adds the desk id's to the user's recipients" do
        @user.add_recipient(@ydmstr)
        @user.recipients[0].desk_id.should == @ydmstr.id
      end

      it "doesn't not add any duplicate recipients" do
        @user.add_recipient(@ydmstr)
        size1 = @user.recipients.size
        @user.add_recipient(@ydmstr)
        size2 = @user.recipients.size
        size2.should == size1
      end
    end
    
    describe "recipient_desk_ids" do

      before(:each) do
        @ydmstr = Desk.create!(name: "Yard Master", abrev: "YDMSTR", job_type: "ops")
        @glhse = Desk.create!(name: "Glasshouse", abrev: "GLHSE", job_type: "ops")
        @user.add_recipient(@ydmstr)
        @user.add_recipient(@glhse)
      end

      it "returns an array of the user's recipient's desk_ids" do
        @user.recipient_desk_ids.should == [@ydmstr.id, @glhse.id]
      end
    end

    describe "timestamp_poll" do

      before(:each) do
        @time = Time.now
        @user.timestamp_poll(@time)
      end

      it "sets the lastpoll attribute to the given time" do
        @user.lastpoll.should == @time
      end
    end    

    describe "set_online" do

      before { @user.set_online }

      it "sets the user's online status to true" do
        @user.reload
        @user.status.should be_true
      end
    end

    describe "set_offline" do

      before do 
        @user.set_online
        @user.set_offline
      end

      it "sets the user's online status to false" do
        @user.reload
        @user.status.should be_false
      end
    end

    describe "messaging?" do
      
      let(:cusn) { Desk.create!(name: "CUS North", abrev: "CUSN", job_type: "td") }
      let(:cuss) { Desk.create!(name: "CUS South", abrev: "CUSS", job_type: "td") }

      before do 
        @recipient = FactoryGirl.create(:recipient, user: @user, desk_id: cusn.id)
      end
      
      it "returns true if the given desk is a recipient of the user" do
        @user.messaging?(cusn.id).should be_true
        @user.messaging?(cuss.id).should be_false
      end

      it "returns the recipient_id associated with the given desk_id" do
        @user.messaging?(cusn.id).should eq(@recipient.id)
      end
    end
  end
end
