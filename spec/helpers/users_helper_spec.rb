require 'spec_helper'

describe "UsersHelper" do
  include UsersHelper

  describe "#updating_user_admin_status?" do

    context "if params hash contains user[:admin]" do

      let(:params) {{ "user" => { "admin" => "1" } }}

      it "returns true"  do
        updating_user_admin_status?.should be_true
      end
    end

    context "if params hash does not contain user[:admin]" do

      let(:params) {{ "user" => { "user_name" => "bill", "password" => "secret", "password_confirmation" => "secret" } }}

      it "returns false"  do
        updating_user_admin_status?.should be_false
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
