require 'spec_helper'

describe "UsersHelper" do
  include UsersHelper

  describe "#promoting_user_admin_status?" do

    context "if params hash contains user[:admin] = 1" do

      let(:params) {{ "user" => { "admin" => "1" } }}

      it "returns true"  do
        promoting_user_admin_status?.should be_true
      end
    end

    context "if params hash does not contain user[:admin] = 1" do

      let(:params) {{ "user" => { "admin" => "0" } }}

      it "returns false"  do
        promoting_user_admin_status?.should be_false
      end
    end
  end

  describe "#demoting_user_admin_status?" do

    context "if params hash contains user[:admin] = 0" do

      let(:params) {{ "user" => { "admin" => "0" } }}

      it "returns true"  do
        demoting_user_admin_status?.should be_true
      end
    end

    context "if params hash does not contain user[:admin] = 0" do

      let(:params) {{ "user" => { "admin" => "1" } }}

      it "returns false"  do
        demoting_user_admin_status?.should be_false
      end
    end
  end

  describe "#deletion_confirmed?" do

    let(:params) { { user: { user_name: "frank" }, a_key: "a value" } }

    it "returns false if the params does not contain key 'commit' with value =~ 'Yes delete user'" do
      deletion_confirmed?.should_not be_true
    end

    it "returns true if the params contains key 'commit' with value =~ 'Yes delete user'" do
      params.merge!("commit" => "Yes delete user bob")
      deletion_confirmed?.should be_true
    end
  end

  describe "#deletion_cancelled?" do

    let(:params) { { user: { user_name: "frank" }, a_key: "a value" } }

    it "returns false if the params does not contain key 'commit' with value 'Cancel'" do
      deletion_cancelled?.should_not be_true
    end

    it "returns true if the params contains key 'commit' with value 'Cancel'" do
      params.merge!("commit" => "Cancel")
      deletion_cancelled?.should be_true
    end
  end
end
