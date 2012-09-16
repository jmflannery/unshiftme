require 'spec_helper'

describe Transcript do

  before(:each) do
    @user = FactoryGirl.create(:user)
    @transcript = @user.transcripts.build(start_time: "2012-06-22 16:30",
                                          end_time: "2012-06-22 17:15")
  end

  subject { @transcript }

  it { should respond_to(:transcript_user_id) }
  it { should respond_to(:transcript_workstation_id) }
  it { should respond_to(:start_time) }
  it { should respond_to(:end_time) }

  it { should be_valid }

  describe "when start_time is not present" do
    before { @transcript.start_time = nil }
    it { should_not be_valid }
  end

  describe "when end_time is not present" do
    before { @transcript.end_time = nil }
    it { should_not be_valid }
  end
  
#  describe "when start_time is too low" do
#    before { @transcript.start_time = 5.days.ago }
#    it { should_not be_valid }
#  end

#  describe "when start_time is too high" do
#    before { @transcript.start_time = 1.second.ago }
#    it { should_not be_valid }
#  end

#  describe "when end_time is too low" do
#    before { @transcript.end_time = 5.days.ago }
#    it { should_not be_valid }
#  end

#  describe "when end_time is too high" do
#    before { @transcript.end_time = 1.second.ago }
#    it { should_not be_valid }
#  end

  describe "default scope order" do
    before do
      subject.save
      @t2 = FactoryGirl.create(:transcript)
    end

    it "defualts to descending order" do
      Transcript.all.should == [@t2, subject]
    end
  end

  describe "user associations" do

    it { should respond_to(:user) }

    it "should have the right user associated user" do
      @transcript.user_id.should == @user.id
      @transcript.user.should == @user
    end
  end

  describe "named scope" do

    before(:each) do
      @user = FactoryGirl.create(:user)
      @transcript = FactoryGirl.create(:transcript, user: @user)
      @transcript1 = FactoryGirl.create(:transcript, user: @user)
      @other_transcript = FactoryGirl.create(:transcript)
    end

    describe "for_user" do
      
      it "returns all transcripts owned by the given user" do
        @transcripts = Transcript.for_user(@user)
        @transcripts.should include @transcript
        @transcripts.should include @transcript1
        @transcripts.should_not include @other_transcript
      end
    end
  end

  describe "#name" do

    context "with a transcript user and workstation" do
      let(:transcript_user) { FactoryGirl.create(:user, user_name: "jack") }
      let(:cusn) { FactoryGirl.create(:workstation, name: "CUS North", abrev: "CUSN", job_type: "td") }
      before do 
        subject.update_attribute(:transcript_user_id, transcript_user.id)
        subject.update_attribute(:transcript_workstation_id, cusn.id)
      end

      it "returns the name including the transcript user and workstation and start and end_times" do
        subject.name.should == "Transcript for CUSN jack from Jun 22 2012 16:30 to Jun 22 2012 17:15"
      end
    end

    context "with a transcript user and no workstation" do
      let(:transcript_user) { FactoryGirl.create(:user, user_name: "jack") }
      before do 
        subject.update_attribute(:transcript_user_id, transcript_user.id)
        subject.update_attribute(:transcript_workstation_id, 0)
      end

      it "returns the name including the transcript user and start and end_times" do
        subject.name.should == "Transcript for jack from Jun 22 2012 16:30 to Jun 22 2012 17:15"
      end
    end

    context "with a trancript workstation and no user" do
      let(:cusn) { FactoryGirl.create(:workstation, name: "CUS North", abrev: "CUSN", job_type: "td") }
      before do 
        subject.update_attribute(:transcript_workstation_id, cusn.id)
        subject.update_attribute(:transcript_user_id, 0)
      end

      it "returns the name including the transcript workstation and start and end_times" do
        subject.name.should == "Transcript for CUSN from Jun 22 2012 16:30 to Jun 22 2012 17:15"
      end
    end

    describe "#to_json" do
    
      let(:transcript_user) { FactoryGirl.create(:user, user_name: "jack") }
      let(:cusn) { FactoryGirl.create(:workstation, name: "CUS North", abrev: "CUSN", job_type: "td") }
      let(:expected) {{
        start_time: subject.start_time.to_s,
        end_time: subject.end_time.to_s,
        user: transcript_user.id,
        workstation: cusn.id
      }}

      context "with a transcript user and workstation" do
        before do 
          subject.update_attribute(:transcript_user_id, transcript_user.id)
          subject.update_attribute(:transcript_workstation_id, cusn.id)
        end

        it "returns json including the user, workstation, start and end times" do
          subject.to_json.should == expected.as_json
        end
      end

      context "with a transcript user and no workstation" do
        before do 
          subject.update_attribute(:transcript_user_id, transcript_user.id)
          expected.delete(:workstation)
        end

        it "returns json including the user, start and end times" do
          subject.to_json.should == expected.as_json
        end
      end

      context "with a transcript workstation and no user" do
        before do 
          subject.update_attribute(:transcript_workstation_id, cusn.id)
          expected.delete(:user)
        end

        it "returns json including the workstation, start and end times" do
          subject.to_json.should == expected.as_json
        end
      end
    end
  end
end

