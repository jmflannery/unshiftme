# == Schema Information
#
# Table name: recipients
#
#  id                :integer         not null, primary key
#  user_id           :integer
#  recipient_user_id :integer
#  created_at        :datetime
#  updated_at        :datetime
#

require 'spec_helper'

describe Recipient do
  before(:each) do
    @sender = FactoryGirl.create(:user)
    @reciever = FactoryGirl.create(:user)
    @attr = { :recipient_user_id => @reciever.id }
    @recipient = @sender.recipients.create!(@attr)
  end

  it "should create a new instance given valid attributes" do
    @sender.recipients.create!(@attr)
  end

  describe "user associations" do

    it "should have a user attribute" do
      @recipient.should respond_to(:user)
    end

    it "should have the right user associated user" do
      @recipient.user_id.should == @sender.id
      @recipient.user.should == @sender
    end
  end
end
