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
    @user = User.new(first_name: "Sam", middle_initial: "Q", last_name: "Smith",
                     user_name: "sqsmith", email: "xxx@xxx.xxx", password: "foobar",
                     password_confirmation: "foobar")
  end

  subject { @user }

  it { should respond_to(:first_name) }
  it { should respond_to(:middle_initial) }
  it { should respond_to(:last_name) }
  it { should respond_to(:user_name) }
  it { should respond_to(:email) }
  it { should respond_to(:password) }
  it { should respond_to(:password_confirmation) }
  it { should respond_to(:admin) }
  it { should respond_to(:authenticate) }

  it { should be_valid }

  describe "with admin attribute set to true" do
    before { @user.toggle!(:admin) }

    it { should be_admin }
  end

  describe "when first_name is not present" do
    before { @user.first_name = " " }
    it { should_not be_valid }
  end

  describe "when last_name is not present" do
    before { @user.last_name = " " }
    it { should_not be_valid }
  end

  describe "when user_name is not present" do
    before { @user.user_name = " " }
    it { should_not be_valid }
  end

  describe "when email is not present" do
    before { @user.email = " " }
    it { should_not be_valid }
  end

  describe "when user_name is already taken" do
    before do
      user_with_same_name = FactoryGirl.create(:user, user_name: @user.user_name) 
    end

    it { should_not be_valid }
  end

  describe "when email is already taken" do
    before do
      user_with_same_email = FactoryGirl.create(:user, email: @user.email) 
    end

    it { should_not be_valid }
  end

  describe "when email format is invalid" do
    it "should not be invalid" do
      addresses = %w[user@foo,com user_at_foo.org example.user@foo.]
      addresses.each do |invalid_address|
        @user.email = invalid_address
        @user.should_not be_valid
      end
    end
  end

  describe "when email format is valid" do
    it "should be valid" do
      addresses = %w[user@foo.com A_USER@f.b.org frst.lst@foo.jp a+b@baz.cn]
      addresses.each do |valid_address|
        @user.email = valid_address
        @user.should be_valid
      end
    end
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
  
  describe "method" do
    
    before(:each) do
      @user.save
      @user1 = FactoryGirl.create(:user, status: true)
      @user2 = FactoryGirl.create(:user, status: true)
      @user3 = FactoryGirl.create(:user, status: true)
      FactoryGirl.create(:recipient, user: @user, recipient_user_id: @user1.id)
      @user_ids = [@user1.id, @user2.id, @user3.id]
      @available_users = [@user2, @user3]
    end

    describe "available_users" do

      let(:users) { User.available_users(@user) }

      it "returns a list users with online status" do
        users.size.should == @available_users.size
        users.each do |user|
          user.status.should be_true
        end
      end

      it "doesn't return the given user" do
        users.should_not include(@user)
      end

      it "doesn't return users who are already recipients of the given user" do
        users.should_not include(@user1)
      end 
    end

    describe "add_recipients" do

      before { @user.add_recipients(@user_ids) }

      it "adds the list of user IDs to the user's recipients" do
        @user.recipients.size.should == @user_ids.size
        @user.recipients.each do |recipient|
          @user_ids.should include recipient.recipient_user_id
        end
      end

      it "doesn't add any duplicate recipients" do
        size1 = @user.recipients.size
        @user.add_recipients(@user_ids)
        size2 = @user.recipients.size
        size1.should == size2
      end
    end

    describe "add_recipient" do

      before { @user.add_recipient(@user1.id) }

      it "adds the user ID to the user's recipients" do
        @user.recipients.size.should == 1
        @user.recipients[0].recipient_user_id.should == @user1.id
      end

      it "doesn't not add any duplicate recipients" do
        size1 = @user.recipients.size
        @user.add_recipient(@user1.id)
        size2 = @user.recipients.size
        size1.should == size2
      end
    end

    describe "recipient_user_ids" do

      before { @user.add_recipients(@user_ids) }

      it "returns an array of the user's recipient's user_ids" do
        @user.recipient_user_ids == @user_ids
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
        @user.status.should be_true
      end
    end

    describe "set_offline" do

      before { @user.set_offline }

      it "sets the user's online status to false" do
        @user.status.should be_false
      end
    end

    describe "remove_stale_recipients" do
      
      before(:each) do
        @user.add_recipients(@user_ids)
        @user.recipient_user_ids.each do |id|
          r_user = User.find(id)
          r_user.timestamp_poll(Time.now)
        end
      end
    
      it "removes recipients who have a status of false" do
        @user2.set_offline
        @user.remove_stale_recipients
        @user.reload
        @user.recipient_user_ids.should include(@user1.id)
        @user.recipient_user_ids.should_not include(@user2.id)
      end

      it "removes recipients who haven't polled for messages in the last 4 seconds" do
        @user2.timestamp_poll(Time.now - 4)
        @user.remove_stale_recipients
        @user.reload
        @user.recipient_user_ids.should include(@user1.id)
        @user.recipient_user_ids.should_not include(@user2.id)
      end

      it "sets the user's stale recipients to offline status" do
        @user1.timestamp_poll(Time.now - 4)
        @user2.timestamp_poll(Time.now - 4)
        @user.remove_stale_recipients
        @user1.reload
        @user2.reload
        @user1.status.should be_false
        @user2.status.should be_false
      end
    end
  end
end
