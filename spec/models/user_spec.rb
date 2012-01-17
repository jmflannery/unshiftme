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
    end

    describe "available_users" do

      before(:each) do
        @user3 = Factory(:user, @user_attr1)
        @user4 = Factory(:user, @user_attr2)
        @recipient = Factory(:recipient, :user => @user, :recipient_user_id => @user4.id)
      end

      it "should return an Array of users" do
        users = User.available_users(@user)
        users.should be_kind_of(Array)
        users[0].should be_kind_of(User)        
      end

      it "should not return the given user" do
        users = User.available_users(@user)
        users.should_not include(@user)
      end

      it "should not return users who are already recipients of the given user" do
        users = User.available_users(@user)
        users.should_not include(@user4)
      end 
    end

    describe "add_recipients" do

      it "should add the list of user IDs to the user's recipients" do
        user_ids = [1,2,3]
        @user.add_recipients(user_ids)
        recipients = Recipient.of_user(@user.id)
        recipients.size.should == user_ids.size
        recipients.each do |recipient|
          user_ids.should include recipient.recipient_user_id
        end
      end

      it "should not add any duplicate recipients" do
        user_ids = [1,2,3]
        @user.add_recipients(user_ids)
        size1 = Recipient.of_user(@user.id).size
        @user.add_recipients(user_ids)
        size2 = Recipient.of_user(@user.id).size
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
  end
end

