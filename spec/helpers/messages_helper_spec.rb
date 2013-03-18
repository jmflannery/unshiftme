require 'spec_helper'

describe MessagesHelper do
  include MessagesHelper

  describe "#broadcast" do

    let(:recipient1) { stub('recipient1', user: stub('user', id: 1, user_name: 'bob')) }
    let(:recipient2) { stub('recipient2', user: stub('user', id: 2, user_name: 'jeff')) }
    let(:recipients) { [recipient1, recipient2] }
    let(:user) { stub('User', recipients: recipients) }
    let(:message) { stub('Message', user: user) }

    it "sends the message to each recipient workstation" do
      recipient_count = user.recipients.size
      MessagePresenter.should_receive(:new).exactly(recipient_count).times
      PrivatePub.should_receive(:publish_to).exactly(recipient_count).times
      broadcast(message)
    end

    it "does not broadcast a message more than once to a user working multiple jobs" do
      user.stub!(recipients: [recipient1, recipient1])
      MessagePresenter.should_receive(:new).exactly(1).times
      PrivatePub.should_receive(:publish_to).exactly(1).times
      broadcast(message)
    end
  end
end 
