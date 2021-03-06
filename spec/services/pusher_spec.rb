require 'spec_helper'

describe Pusher do

  describe ".push_message" do

    let(:recipient1) { double('recipient1', user: double('user', id: 1, user_name: 'bob')) }
    let(:recipient2) { double('recipient2', user: double('user', id: 2, user_name: 'jeff')) }
    let(:recipients) { [recipient1, recipient2] }
    let(:user) { double('User', recipients: recipients) }
    let(:message) { double('Message', user: user) }

    it "pushes the message to each recipient workstation" do
      recipient_count = user.recipients.size
      MessagePresenter.should_receive(:new).exactly(recipient_count).times
      PrivatePub.should_receive(:publish_to).exactly(recipient_count).times
      Pusher.push_message(message)
    end

    it "does not push a message more than once to a user working multiple jobs" do
      user.stub(recipients: [recipient1, recipient1])
      MessagePresenter.should_receive(:new).exactly(1).times
      PrivatePub.should_receive(:publish_to).exactly(1).times
      Pusher.push_message(message)
    end
  end
end
