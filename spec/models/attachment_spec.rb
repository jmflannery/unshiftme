require 'spec_helper'

describe Attachment do

  let(:user) { FactoryGirl.create(:user) }
  let(:attr) { { payload: file } }
  let(:file) { File.new(Rails.root + "spec/fixtures/files/test_file.txt") }
  
  before(:each) do
    @attachment = user.attachments.build(attr)
  end

  subject { @attachment }

  it { should respond_to(:payload) }
  it { should respond_to(:payload_url) }
  it { should respond_to(:payload_identifier) }

  it { should be_valid }


  describe "user associations" do

    before(:each) { @attachment.save }

    it { should respond_to(:user) }

    it "should have the right user associated user" do
      @attachment.user_id.should == user.id
      @attachment.user.should == user
    end
  end

  describe "method" do

    describe "set_recievers" do 

      let(:cusn) { Workstation.create!(name: "CUS North", abrev: "CUSN", job_type: "td") }
      let(:aml) { Workstation.create!(name: "AML / NOL", abrev: "AML", job_type: "td") }
      
      let(:receiver) { FactoryGirl.create(:user) }

      let(:attachment1) { FactoryGirl.create(:attachment, user: user) }

      before do
        receiver.start_job(cusn.abrev)
        FactoryGirl.create(:message_route, user: user, workstation: cusn)
        FactoryGirl.create(:message_route, user: user, workstation: aml)
        attachment1.set_recievers
      end

      it "sets attachment.recievers to an array of hashes, with workstation_id and user_id" do
        attachment1.recievers.should == [{ workstation_id: cusn.id, user_id: receiver.id }, { workstation_id: aml.id }]
      end
    end
  end
end
