require 'spec_helper'

describe MessageRoute do

  let(:message_route) { MessageRoute.new }
  subject { message_route }

  it { should respond_to(:user_id) }
  it { should respond_to(:workstation_id) }

  it { should belong_to(:user) }
  it { should belong_to(:workstation) }
end

