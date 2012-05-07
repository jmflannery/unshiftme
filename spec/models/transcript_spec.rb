require 'spec_helper'

describe Transcript do

  before(:each) do
    @user = FactoryGirl.create(:user)
    @transcript = @user.transcripts.build(watch_user_id: 22,
                                          start_time: 3.minutes.ago,
                                          end_time: 3.second.ago)
  end

  subject { @transcript }

  it { should respond_to(:watch_user_id) }
  it { should respond_to(:start_time) }
  it { should respond_to(:end_time) }

  it { should be_valid }

  describe "when watch_user_id is not present" do
    before { @transcript.watch_user_id = nil }
    it { should_not be_valid }
  end
  
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
end
