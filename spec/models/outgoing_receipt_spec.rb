require 'spec_helper'

describe OutgoingReceipt do

  before { @outgoing_receipt = OutgoingReceipt.new }
  subject { @outgoing_receipt }

  it { should respond_to(:message_id) }
  it { should respond_to(:workstation_id) }

  it { should belong_to(:message) }
  it { should belong_to(:workstation) }

  it { should_not allow_mass_assignment_of(:workstation_id) }
end

