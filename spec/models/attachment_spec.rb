# == Schema Information
#
# Table name: attachments
#
#  id           :integer         not null, primary key
#  user_id      :integer
#  file         :binary
#  created_at   :datetime        not null
#  updated_at   :datetime        not null
#  name         :string(255)
#  content_type :string(255)
#

require 'spec_helper'

describe Attachment do

  before(:each) do
    @user = Factory(:user)
    @reciever = Factory(:user, name: "Jim", full_name: "Jim Dickson")
    @recipient = Factory(:recipient, user: @user, recipient_user_id: @reciever.id)
    @attr = { name: "my_file.txt", content_type: "text/plain" }
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
end
