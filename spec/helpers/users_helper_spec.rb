require 'spec_helper'

describe "UsersHelper" do
  include UsersHelper

  describe "#parse_params_for_desks" do

    let(:params) { { a_key: "a_value", "CUSN" => "1", "AML" => "1", another_key: "another value" } }
    before(:each) do
      FactoryGirl.create(:desk, name: "CUS North", abrev: "CUSN")
      FactoryGirl.create(:desk, name: "AML / NOL", abrev: "AML")
    end

    it "parses the params hash and returns and array the found desks" do
      parse_params_for_desks(params).should == ["CUSN", "AML"]
    end
  end
end
