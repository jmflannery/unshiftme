require 'spec_helper'

describe Transcript do

  before(:each) do
    @user = FactoryGirl.create(:user)
    @transcript = @user.transcripts.build(start_time: "2012-06-22 16:30",
                                          end_time: "2012-06-22 17:15")
  end

  subject { @transcript }

  it { should respond_to(:user_id) }
  it { should respond_to(:transcript_user_id) }
  it { should respond_to(:start_time) }
  it { should respond_to(:end_time) }

  it { should be_valid }

  it { should belong_to(:user) }
  it { should belong_to(:transcript_user) }

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

    let(:transcript_user) { FactoryGirl.create(:user, user_name: "jack") }
    before do 
      subject.update_attribute(:transcript_user_id, transcript_user.id)
    end

    it "returns the full name of the transcript" do
      subject.name.should == "Transcript for jack from Jun 22 2012 16:30 to Jun 22 2012 17:15"
    end
  end

  describe "#display_messages" do

    it "gets the display_messages of the transcript_user" do
      subject.start_time = double(:start_time).as_null_object
      subject.end_time = double(:end_time).as_null_object
      subject.transcript_user = FactoryGirl.create(:user)
      subject.transcript_user.should_receive(:display_messages).
        with(start_time: subject.start_time, end_time: subject.end_time)
      subject.display_messages
    end
  end

  describe "#as_json" do
  
    let(:transcript_user) { FactoryGirl.create(:user, user_name: "jack") }
    let!(:message) { FactoryGirl.create(:message, content: "holla", user: transcript_user, created_at: "2012-06-22 17:01") }
    let(:expected) {{
      start_time: subject.start_time.to_s,
      end_time: subject.end_time.to_s,
      user: transcript_user.id,
      messages: subject.display_messages.map { |msg| MessagePresenter.new(msg, transcript_user).as_json(transcript: true) }
    }}
    before do
      subject.update_attribute(:transcript_user, transcript_user)
    end

    it "returns json including the user, start and end times, and messages" do
      subject.as_json(user: transcript_user).should == expected.as_json
    end
  end
end
