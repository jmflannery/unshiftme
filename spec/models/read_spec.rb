require 'spec_helper'

describe Read do

  before { @read = Read.new }
  subject { @read }

  it { should respond_to(:user_id) }
  it { should respond_to(:message_id) }

  it { should belong_to(:user) }
  it { should belong_to(:message) }
end

