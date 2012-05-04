require 'spec_helper'

describe Attachment do

  let(:user) { FactoryGirl.create(:user) }
  let(:attr) { { payload: file } }
  let(:file) { File.new(Rails.root + "spec/fixtures/files/test_file.txt") }
  
  before(:each) do
    @attachment = user.attachments.build(attr)
  end

  subject { @attachment }

  it { should respond_to(:payload_file_name) }
  it { should respond_to(:payload_content_type) }
  it { should respond_to(:payload_file_size) }

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

      #let(:cusn) { Desk.create!(name: "CUS North", abrev: "CUSN", job_type: "td") }
      #let(:aml) { Desk.create!(name: "AML / NOL", abrev: "AML", job_type: "td") }
      
      #let(:reciever) { FactoryGirl.create(:user) }

      #let(:attachment1) { FactoryGirl.create(:attachment, user: @sender) }

      before do
        @cusn = Desk.create!(name: "CUS North", abrev: "CUSN", job_type: "td")
        @aml = Desk.create!(name: "AML / NOL", abrev: "AML", job_type: "td")
        @sender = FactoryGirl.create(:user, first_name: "Sender")
        @reciever = FactoryGirl.create(:user, first_name: "Reciever")
        @attachment1 = FactoryGirl.create(:attachment, user: @sender)  
        @reciever.authenticate_desk(@cusn.abrev => 1)
        FactoryGirl.create(:recipient, user: @sender, desk_id: @cusn.id)
        FactoryGirl.create(:recipient, user: @sender, desk_id: @aml.id)
        @attachment1.set_recievers
      end

      it "sets attachment.recievers to an array of hashes, with desk_id and user_id" do
        @attachment1.recievers.should == [{ desk_id: @cusn.id, user_id: @reciever.id }, { desk_id: @aml.id }]
      end
    end
  end
end
