# == Schema Information
#
# Table name: users
#
#  id                 :integer         not null, primary key
#  name               :string(255)
#  full_name          :string(255)
#  email              :string(255)
#  created_at         :datetime
#  updated_at         :datetime
#  encrypted_password :string(255)
#  salt               :string(255)
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

    #describe "has_password? method" do

    #  it "should be true if passwords match" do
    #    @user.has_password?(@attr[:password]).should be_true
    #  end

    #  it "should be false if the passwords don't match" do
    #    @user.has_password?("invalid").should be_false
    #  end
    #end

    describe "authenticate method" do

      it "should return nil on name/password mismatch" do
        wrong_password_user = User.authenticate(@attr[:name], "wrongpassword")
        wrong_password_user.should be_nil
      end

      it "should return nil for an an registered name" do
        nonexistant_user = User.authenticate("foo@bar.com", @attr[:password])
        nonexistant_user.should be_nil
      end

      it "should return the user on name/password match" do
        matching_user = User.authenticate(@attr[:name], @attr[:password])
        matching_user.should == @user
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
  
end

