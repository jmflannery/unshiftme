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
    @attr = {
      :name => "XXX",
      :full_name => "Xxx User",
      :email => "xxx@xxx.xxx",
      :password => "foobar",
      :password_confirmation => "foobar"
    }
  end

  it "should create a new instance given valid attributes" do
    User.create!(@attr)
  end

  describe "password validations" do

    it "should require a password" do
      User.new(@attr.merge(:password => "", :password_confirmation => "")).should_not be_valid
    end

    it "should require a matching password confirmation" do
      User.new(@attr.merge(:password_confirmation => "Invalid")).should_not be_valid
    end

    it "should reject short passwords" do
      short = "a" * 5
      hash = @attr.merge(:password => short, :password_confirmation => short)
      User.new(hash).should_not be_valid
    end

    it "should reject long passwords" do
      long = "a" * 41
      hash = @attr.merge(:password => long, :password_confirmation => long)
      User.new(hash).should_not be_valid
    end

  end

  describe "password encryption" do

    before(:each) do
      @user = User.create!(@attr)
    end

    it "should have a password digest attribute" do
      @user.should respond_to(:password_digest)
    end

    it "should set the encrypted password" do
      @user.password_digest.should_not be_blank
    end

    describe "authenticate method" do
      
      before(:each) do
        @user = User.create!(@attr)
      end
      
      it "should have an authenticate method" do
        @user.should respond_to(:authenticate)
      end

      it "should return false on wrong password" do
        assert_equal(false, @user.authenticate("wrongpassword"))
      end

      it "should return authencated user given the correct password" do
        assert_equal(@user, @user.authenticate(@attr[:password]))
      end

    end
  end
  
  describe "message associations" do

    before(:each) do
      @user = User.create(@attr)
      @msg2 = Factory(:message, :user => @user, :created_at => 1.minute.ago)
      @msg1 = Factory(:message, :user => @user, :created_at => 1.hour.ago)
    end

    it "should have a messages attribute" do
      @user.should respond_to(:messages)
    end

    it "should have the right messages in the right order" do
      @user.messages.should == [@msg1, @msg2]
    end
  end

  describe "method" do
    
    before(:each) do
      @user = Factory(:user)
      @user_attr1 = { :name => "Wally", :full_name => "Wally Wallerson", :status => true }
      @user_attr2 = { :name => "Sally", :full_name => "Sally Fields", :status => true }
      @user_attr3 = { :name => "Jimmy", :full_name => "Jimmy Johnson", :status => true }
    end

    describe "available_users" do

      before(:each) do
        @user1 = Factory(:user, @user_attr1)
        user2 = Factory(:user, @user_attr2)
        user3 = Factory(:user, @user_attr3)
        Factory(:recipient, :user => @user, :recipient_user_id => @user1.id)
      end

      it "should return an Array of users with online status" do
        users = User.available_users(@user)
        users.should be_kind_of(Array)
        users.size.should == 2
        users.each do |user|
          user.should be_kind_of(User)
          user.status.should be_true
        end
      end

      it "should not return the given user" do
        users = User.available_users(@user)
        users.should_not include(@user)
      end

      it "should not return users who are already recipients of the given user" do
        users = User.available_users(@user)
        users.should_not include(@user1)
      end 
    end

    describe "add_recipients" do

      it "should add the list of user IDs to the user's recipients" do
        user_ids = [1,2,3]
        @user.add_recipients(user_ids)
        recipients = Recipient.for_user(@user.id)
        recipients.size.should == user_ids.size
        recipients.each do |recipient|
          user_ids.should include recipient.recipient_user_id
        end
      end

      it "should not add any duplicate recipients" do
        user_ids = [1,2,3]
        @user.add_recipients(user_ids)
        size1 = Recipient.for_user(@user.id).size
        @user.add_recipients(user_ids)
        size2 = Recipient.for_user(@user.id).size
        size1.should == size2
      end
    end

    describe "recipient_user_ids" do

      it "should return an array of the user's recipient's user_ids" do
        user_ids = [1,2,3]
        @user.add_recipients(user_ids)
        recipient_user_ids = @user.recipient_user_ids
        recipient_user_ids.should == user_ids
      end
    end

    describe "timestamp_poll" do

      it "should set the lastpoll attribute to the given time" do
        time = Time.now
        @user.timestamp_poll(time)
        @user.lastpoll.should == time
      end
    end    

    describe "set_online" do

      it "should set the user's online status to true" do
        @user.set_online
        @user.status.should be_true
      end
    end

    describe "set_offline" do

      it "should set the user's online status to false" do
        @user.set_offline
        @user.status.should be_false
      end
    end

    describe "remove_stale_recipients" do
      
      before(:each) do
        @user3 = Factory(:user, @user_attr1)
        @user4 = Factory(:user, @user_attr2)
        @recipient3 = Factory(:recipient, :user => @user, :recipient_user_id => @user3.id)
        @recipient4 = Factory(:recipient, :user => @user, :recipient_user_id => @user4.id)
      end
    
      it "should remove recipients who have a status of false" do
        @user3.timestamp_poll(Time.now)
        @user4.timestamp_poll(Time.now)
        @user4.set_offline
        @user.remove_stale_recipients
        @user.reload
        @user.recipients.should include(@recipient3)
        @user.recipients.should_not include(@recipient4)
      end

      it "should remove recipients who haven't polled for messages in the last 4 seconds" do
        @user3.timestamp_poll(Time.now)
        @user4.timestamp_poll(Time.now - 4)
        @user.remove_stale_recipients
        @user.reload
        @user.recipients.should include(@recipient3)
        @user.recipients.should_not include(@recipient4)
      end

      it "should set the user's stale recipients to offline status" do
        @user3.timestamp_poll(Time.now - 4)
        @user4.timestamp_poll(Time.now - 4)
        @user.remove_stale_recipients
        @user3.reload
        @user4.reload
        @user3.status.should be_false
        @user4.status.should be_false
      end
    end
  end
end
