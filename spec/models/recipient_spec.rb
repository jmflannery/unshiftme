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
    @sender = Factory(:user)
    @reciever = Factory(:user, :name => "Jim", :full_name => "Jim Dickson")
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

  describe "my_recipients method" do
    
    before(:each) do
      x = 0
      while x < 16 do
        user = Factory(:user)
        @sender.recipients.create!(:recipient_user_id => user.id)    
        x += 1
      end 
    end

    it "should return all of the user's recipients as an array of 8 recipient arrays" do
      recipients = Recipient.my_recipients(@sender.id)
      recipients.should be_kind_of(Array)
      recipients.size.should == 3
      recipients[0].should be_kind_of(Array)
      recipients[0].size.should == 8
      recipients[1].should be_kind_of(Array)
      recipients[1].size.should == 8
      recipients[2].should be_kind_of(Array)
      recipients[2].size.should == 1
    end
  end
end

