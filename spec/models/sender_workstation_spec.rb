require 'spec_helper'

describe SenderWorkstation do

  before { @sender_workstation = SenderWorkstation.new }
  subject { @sender_workstation }

  it { should respond_to(:message_id) }
  it { should respond_to(:workstation_id) }

  it { should belong_to(:message) }
  it { should belong_to(:workstation) }

  it { should_not allow_mass_assignment_of(:workstation_id) }
end
