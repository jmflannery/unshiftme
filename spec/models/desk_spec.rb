require 'spec_helper'

describe Desk do

  before(:each) do
    @desk = Desk.new(name: "CUS North", abrev: "CUSN", job_type: "td")
  end

  subject { @desk }

  it { should respond_to(:name) }
  it { should respond_to(:abrev) }
  it { should respond_to(:job_type) }

  it { should be_valid }

  describe "scope" do
    
    before(:each) do
      @cusn = Desk.create!(name: "CUS North", abrev: "CUSN", job_type: "td")
      @cuss = Desk.create!(name: "CUS South", abrev: "CUSS", job_type: "td")
      @aml = Desk.create!(name: "AML / NOL", abrev: "AML", job_type: "td")
      @ydctl = Desk.create!(name: "Yard Control", abrev: "YDCTL", job_type: "ops")
      @ydmstr = Desk.create!(name: "Yard Master", abrev: "YDMSTR", job_type: "ops")
      @glhse = Desk.create!(name: "Glasshouse", abrev: "GLHSE", job_type: "ops")
    end

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
        @ops_desks.should include @glhse
        @td_desks.should_not include @glhse
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

    describe "description" do

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
end
