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

  let(:sender) { FactoryGirl.create(:user) }
  let(:reciever) { FactoryGirl.create(:user) }

  let(:cusn) { Workstation.create!(name: "CUS North", abrev: "CUSN", job_type: "td") }
  let(:attr) { { workstation_id: cusn.id } }

  let(:recipient) { sender.recipients.create!(attr) }

  before(:each) do
    reciever.start_job(cusn.abrev)
  end

  it "should create a new instance given valid attributes" do
    sender.recipients.create!(attr)
  end

  describe "user associations" do

    it "should have a user attribute" do
      recipient.should respond_to(:user)
    end

    it "should have the right user associated user" do
      recipient.user_id.should == sender.id
      recipient.user.should == sender
    end
  end

  describe "workstation association" do
    it { recipient.should belong_to(:workstation) }
  end
end
