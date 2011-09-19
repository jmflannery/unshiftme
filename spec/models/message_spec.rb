require 'spec_helper'

describe Message do
  before(:each) do
    @user = Factory(:user)
    @attr = { :content => "value for content" }
  end
  
  it "should create a new instance given valid attibutes" do
    @user.messages.create!(@attr)
  end
  
  describe "user associations" do

    before(:each) do
      @message = @user.messages.create(@attr)
    end

    it "should have a user attribute" do
      @message.should respond_to(:user)
    end

    it "should have the right associated user" do
      @message.user_id.should == @user.id
      @message.user.should == @user
    end
  end
  
  describe "validations" do

    it "should require a user id" do
      Message.new(@attr).should_not be_valid
    end

    it "should require nonblank content" do
      @user.messages.build(:content => "  ").should_not be_valid
    end

    it "should reject long content" do
      @user.messages.build(:content => "a" * 141).should_not be_valid
    end
  end
  
end
