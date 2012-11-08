require 'spec_helper'

describe "WorkstationssHelper" do
  include WorkstationsHelper

  let(:params) { { user: { user_name: "Mit" }, a_key: "a value", "CUSN" => "1", "AML" => "1", another_key: "another value" } }

  before(:each) do
    FactoryGirl.create(:workstation, name: "CUS North", abrev: "CUSN")
    FactoryGirl.create(:workstation, name: "AML / NOL", abrev: "AML")
  end

  describe "#parse_params_for_workstations" do

    it "parses the params hash and returns an array of the found workstation abrevs" do
      parse_params_for_workstations(params).should == %w(CUSN AML)
    end
  end

  describe "#merge_workstation_params" do
    
    it "merges the normal workstations array into the params[:user] hash" do
      merged_params = merge_workstation_params(params)
      merged_params[:user].should have_key :normal_workstations
      merged_params[:user][:normal_workstations].should == %w(CUSN AML)
    end
  end
end

