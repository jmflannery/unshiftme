require 'spec_helper'

describe IncomingReceipt do

  before { @incoming_message = IncomingReceipt.new }
  subject { @incoming_message }

  it { should respond_to(:message_id) }
  it { should respond_to(:workstation_id) }
  it { should respond_to(:user_id) }

  it { should belong_to(:message) }
  it { should belong_to(:workstation) }
  it { should belong_to(:user) }
end

