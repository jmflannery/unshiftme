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

  it { should belong_to(:user) }

  describe "message_routes/senders association" do

    before { subject.save }
    let!(:message_route) { subject.message_routes.create(user: user) }

    it "should have many message_routes" do
      subject.should have_many :message_routes
    end

    it "should have many senders" do
      subject.should have_many :senders
    end

    it "should have a list of senders" do
      subject.senders.should include user
      message_route.workstation_id.should == subject.id
    end
  end

  describe "incoming_receipts/incoming_messages association" do

    before { subject.save }
    let(:message) { FactoryGirl.create(:message) }
    let!(:incoming_receipt) { subject.incoming_receipts.create(message: message) }

    it "should have many incoming_receipts" do
      subject.should have_many :incoming_receipts
    end

    it "should have many incoming_messages" do
      subject.should have_many :incoming_messages
    end

    it "should have a list of incoming_messages" do
      subject.incoming_messages.should include message
      incoming_receipt.workstation_id.should == subject.id
    end
  end

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
        cusn.set_user(@user)
        aml.set_user(@user)
      end
      
      it "returns a list of all Workstations belonging to the given user" do
        Workstation.of_user(@user.id).should == [Workstation.find_by_abrev("CUSN"), Workstation.find_by_abrev("AML")]
      end
    end
  end

  describe "method" do

    describe "#set_user" do
      
      it "sets the workstation's user" do
        subject.set_user(user)
        subject.user.should == user
        subject.user_id.should == user.id
      end
    end

    describe "#description" do
    
      context "when the workstation has a user" do
        before { cusn.set_user(user) }
        it "returns a string of the workstation name and workstation user" do
          cusn.description.should == "#{cusn.name} (#{user.user_name})"
        end 
      end

      context "when the workstation has no user" do
        it "returns a string of the workstation name" do
          cusn.description.should == "#{cusn.name}"
        end
      end
    end

    describe "#user_name" do
    
      context "when the workstation has a user" do
        before { cusn.set_user(user) }
        it "returns a string of the workstation user name" do
          cusn.user_name.should == "#{user.user_name}"
        end 
      end

      context "when the workstation has no user" do
        it "returns an empty string" do
          cusn.user_name.should == ""
        end
      end
    end

  end

  describe "#view_class" do

    context "when the workstation is owned by the given user" do
      before { cusn.set_user(user) }
      it "should have the right view class" do
        cusn.view_class(user).should == "recipient_workstation mine"
      end
    end

    context "when the workstation is a recipient of the given user" do
      let!(:message_route) { FactoryGirl.create(:message_route, user: user, workstation: cusn) }
      it "should have the right view class" do
        cusn.view_class(user).should == "recipient_workstation other on #{message_route.id}"
      end
    end
    
    context "when the workstation is not a recipient of the given user" do
      it "should have the right view class" do
        cusn.view_class(user).should == "recipient_workstation other off"
      end
    end
  end

  describe ".all_short_names" do

    it "should return a list of all the workstation abrevs" do
      Workstation.all_short_names.should include cusn.abrev
      Workstation.all_short_names.should include cuss.abrev
      Workstation.all_short_names.should include aml.abrev
      Workstation.all_short_names.should include ydctl.abrev
      Workstation.all_short_names.should include ydmstr.abrev
      Workstation.all_short_names.should include glhs.abrev
    end
  end
end
