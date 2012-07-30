require 'spec_helper'

describe Desk do

  before(:each) do
    @cusn = Desk.create(name: "CUS North", abrev: "CUSN", job_type: "td")
    @cuss = Desk.create(name: "CUS South", abrev: "CUSS", job_type: "td")
    @aml = Desk.create(name: "AML / NOL", abrev: "AML", job_type: "td")
    @ydctl = Desk.create(name: "Yard Control", abrev: "YDCTL", job_type: "ops")
    @ydmstr = Desk.create(name: "Yard Master", abrev: "YDMSTR", job_type: "ops")
    @glhs = Desk.create(name: "Glasshouse", abrev: "GLHSE", job_type: "ops")
  end

  subject { @cusn }

  it { should respond_to(:name) }
  it { should respond_to(:abrev) }
  it { should respond_to(:job_type) }

  it { should be_valid }

  describe "scope" do
    
    describe "of_type" do

      before(:each) do
        @td_desks = Desk.of_type("td")
        @ops_desks = Desk.of_type("ops")
      end

      it "returns a list of all Desks of the given type" do
        @td_desks.should include @cusn
        @ops_desks.should_not include @cusn
        @td_desks.should include @cuss
        @ops_desks.should_not include @cuss
        @td_desks.should include @aml
        @ops_desks.should_not include @aml
        @ops_desks.should include @ydctl
        @td_desks.should_not include @ydctl
        @ops_desks.should include @ydmstr
        @td_desks.should_not include @ydmstr
        @ops_desks.should include @glhs
        @td_desks.should_not include @glhs
      end
    end

    describe "of_user" do

      before(:each) do
        @user = FactoryGirl.create(:user)
        @params = { key: "val", "CUSN" => 1, "AML" => 1, anotherkey: "val" }
        @user.authenticate_desk(@params)
      end
      
      it "returns a list of all Desks belonging to the given user" do
        Desk.of_user(@user.id).should == [Desk.find_by_abrev("CUSN"), Desk.find_by_abrev("AML")]
      end
    end
  end

  describe "method" do

    describe "#description" do

      let(:user) { FactoryGirl.create(:user, user_name: "epresley") }

      before(:each) do
        @cusn = Desk.create!(name: "CUS North", abrev: "CUSN", job_type: "td")
        @cuss = Desk.create!(name: "CUS South", abrev: "CUSS", job_type: "td")
        user.authenticate_desk(@cusn.abrev => 1)
      end
    
      it "returns a string of the desk name and desk user (if the desk has a user)" do
        @cusn.description == "#{@cusn.name} (#{user.user_name})"
        @cuss.description == "#{@cuss.name}"
      end 
    end
  end

  describe "#view_class" do

    let(:user) { FactoryGirl.create(:user, user_name: "epresley") }
    let(:cusn) { FactoryGirl.create(:desk, name: "CUS North", abrev: "CUSN", job_type: "td") }

    context "when the workstation is owned by the given user" do
      before { user.start_job(cusn.abrev) }
      it "should have the right view class" do
        cusn.view_class(user).should == "recipient_desk mine"
      end
    end

    context "when the workstation is a recipient of the given user" do
      before { @recip = FactoryGirl.create(:recipient, user: user, desk_id: cusn.id) }
      it "should have the right view class" do
        cusn.view_class(user).should == "recipient_desk on #{@recip.id}"
      end
    end
    
    context "when the workstation is not a recipient of the given user" do
      it "should have the right view class" do
        cusn.view_class(user).should == "recipient_desk off"
      end
    end
  end

  describe "class method" do

    describe "all_short_names" do
      it "should return a list of all the desk abrevs of all desks in the system" do
        Desk.all_short_names.should include @cusn.abrev
        Desk.all_short_names.should include @cuss.abrev
        Desk.all_short_names.should include @aml.abrev
        Desk.all_short_names.should include @ydctl.abrev
        Desk.all_short_names.should include @ydmstr.abrev
        Desk.all_short_names.should include @glhs.abrev
      end
    end
  end
end
