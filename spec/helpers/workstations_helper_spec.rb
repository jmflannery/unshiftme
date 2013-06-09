require 'spec_helper'

describe "WorkstationssHelper" do
  include WorkstationsHelper

  let(:params) { { user: { user_name: "Mit" }, a_key: "a value", "CUSN" => "1", "AML" => "1", another_key: "another value" } }

  let!(:cusn) { FactoryGirl.create(:workstation, name: "CUS North", abrev: "CUSN") }
  let!(:aml) { FactoryGirl.create(:workstation, name: "AML / NOL", abrev: "AML") }

  describe "#each_workstation_in" do

    it "parses the params hash and returns an array of the found workstations" do
      each_workstation_in(params).should == ["CUSN", "AML"]
    end
  end
end
