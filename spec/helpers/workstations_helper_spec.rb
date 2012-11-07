require 'spec_helper'

describe "WorkstationssHelper" do
  include WorkstationsHelper

  describe "#parse_params_for_workstations" do

    let(:params) { { a_key: "a_value", "CUSN" => "1", "AML" => "1", another_key: "another value" } }
    before(:each) do
      FactoryGirl.create(:workstation, name: "CUS North", abrev: "CUSN")
      FactoryGirl.create(:workstation, name: "AML / NOL", abrev: "AML")
    end

    it "parses the params hash and returns and array the found workstations" do
      parse_params_for_workstations(params).should == ["CUSN", "AML"]
    end
  end
end

