require 'spec_helper'

describe Attachment do

  before(:each) do
    @user = Factory(:user)
    reciever = Factory(:user, name: "Jim", full_name: "Jim Dickson")
    Factory(:recipient, user: @user, recipient_user_id: reciever.id)
    file = File.new(Rails.root + "spec/fixtures/files/test_file.txt")
    @attr = { payload: file }
    @attachment = @user.attachments.create!(@attr)
  end

  it "should create a new instance given valid attributes" do
    @user.attachments.create!(@attr)
  end

  describe "user associations" do

    it "should have a user attribute" do
      @attachment.should respond_to(:user)
    end

    it "should have the right user associated user" do
      @attachment.user_id.should == @user.id
      @attachment.user.should == @user
    end
  end

  describe "method" do

    describe "set_recievers" do

      it "should set attachment.recievers to the recipients user_ids seperated by commas" do
        @attachment.set_recievers
        recievers = @attachment.recievers.split(/,/)
        recipients = @user.recipients
        recievers.size.should == recipients.size
        recipients.each do |recipient|
          recievers.should include recipient.recipient_user_id.to_s
        end
      end  
    end
  end
end
