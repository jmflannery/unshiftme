require 'spec_helper'

describe Workstation do
  
  let(:user) { FactoryGirl.create(:user, user_name: "epresley") }

  let!(:cusn) { Workstation.create(name: "CUS North", abrev: "CUSN", job_type: "td") }
  let!(:cuss) { Workstation.create(name: "CUS South", abrev: "CUSS", job_type: "td") }
  let!(:aml) { Workstation.create(name: "AML / NOL", abrev: "AML", job_type: "td") }
  let!(:ydctl) { Workstation.create(name: "Yard Control", abrev: "YDCTL", job_type: "ops") }
  let!(:ydmstr) { Workstation.create(name: "Yard Master", abrev: "YDMSTR", job_type: "ops") }
  let!(:glhs) { Workstation.create(name: "Glasshouse", abrev: "GLHSE", job_type: "ops") }

  subject { cusn }

  it { should respond_to(:name) }
  it { should respond_to(:abrev) }
  it { should respond_to(:job_type) }

  it { should be_valid }

  describe "scope" do
    
    describe "of_type" do

      before(:each) do
        @td_workstations = Workstation.of_type("td")
        @ops_workstations = Workstation.of_type("ops")
      end

      it "returns a list of all Workstations of the given type" do
        @td_workstations.should include cusn
        @ops_workstations.should_not include cusn
        @td_workstations.should include cuss
        @ops_workstations.should_not include cuss
        @td_workstations.should include aml
        @ops_workstations.should_not include aml
        @ops_workstations.should include ydctl
        @td_workstations.should_not include ydctl
        @ops_workstations.should include ydmstr
        @td_workstations.should_not include ydmstr
        @ops_workstations.should include glhs
        @td_workstations.should_not include glhs
      end
    end

    describe "of_user" do

      before(:each) do
        @user = FactoryGirl.create(:user)
        @params = { key: "val", "CUSN" => 1, "AML" => 1, anotherkey: "val" }
        @user.authenticate_workstation(@params)
      end
      
      it "returns a list of all Workstations belonging to the given user" do
        Workstation.of_user(@user.id).should == [Workstation.find_by_abrev("CUSN"), Workstation.find_by_abrev("AML")]
      end
    end
  end

  describe "method" do

    describe "#description" do


      before(:each) do
        cusn = Workstation.create!(name: "CUS North", abrev: "CUSN", job_type: "td")
        cuss = Workstation.create!(name: "CUS South", abrev: "CUSS", job_type: "td")
        user.authenticate_workstation(cusn.abrev => 1)
      end
    
      it "returns a string of the workstation name and workstation user (if the workstation has a user)" do
        cusn.description == "#{cusn.name} (#{user.user_name})"
        cuss.description == "#{cuss.name}"
      end 
    end
  end

  describe "#view_class" do

    context "when the workstation is owned by the given user" do
      before { user.start_job(cusn.abrev) }
      it "should have the right view class" do
        cusn.view_class(user).should == "recipient_workstation mine"
      end
    end

    context "when the workstation is a recipient of the given user" do
      let!(:recip) { @recip = FactoryGirl.create(:recipient, user: user, workstation_id: cusn.id) }
      it "should have the right view class" do
        cusn.view_class(user).should == "recipient_workstation on #{recip.id}"
      end
    end
    
    context "when the workstation is not a recipient of the given user" do
      it "should have the right view class" do
        cusn.view_class(user).should == "recipient_workstation off"
      end
    end
  end

  describe "class method" do

    describe "as_json" do

    end

    describe "all_short_names" do
      it "should return a list of all the workstation abrevs of all workstations in the system" do
        Workstation.all_short_names.should include cusn.abrev
        Workstation.all_short_names.should include cuss.abrev
        Workstation.all_short_names.should include aml.abrev
        Workstation.all_short_names.should include ydctl.abrev
        Workstation.all_short_names.should include ydmstr.abrev
        Workstation.all_short_names.should include glhs.abrev
      end
    end
  end
end
