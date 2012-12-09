require 'spec_helper'

describe OutgoingReceipt do

  before { @outgoing_receipt = OutgoingReceipt.new }
  subject { @outgoing_receipt }

  it { should respond_to(:message_id) }
  it { should respond_to(:user_id) }

  it { should belong_to(:message) }
  it { should belong_to(:user) }

  #it { should_not allow_mass_assignment_of(:workstation_id) }
  
  it "has workstations serialized field containing an a array of the user's workstations" do
    subject.save
    subject.update_attribute(:workstations, ['CUSN', 'CUSS'])
    subject.reload.workstations.should == ['CUSN', 'CUSS']
  end
end

