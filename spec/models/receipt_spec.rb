require 'spec_helper'

describe Receipt do

  before { @receipt = Receipt.new }
  subject { @receipt }

  it { should respond_to(:user_id) }
  it { should respond_to(:message_id) }

  it { should belong_to(:user) }
  it { should belong_to(:message) }
end

