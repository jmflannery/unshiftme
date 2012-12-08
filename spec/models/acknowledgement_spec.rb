require 'spec_helper'

describe Acknowledgement do

  before { @ackowledgement = Acknowledgement.new }
  subject { @acknowledgement }

  it { should respond_to(:user_id) }
  it { should respond_to(:message_id) }

  it { should belong_to(:user) }
  it { should belong_to(:message) }
end

