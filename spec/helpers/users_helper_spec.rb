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

  describe "#remove_old_password_key_from_hash" do

    let(:user) {{ old_password: "eddienyc", password: "krotchpotato", password_confirmation: "krotchpotato" }}
    let(:user_wo_oldpassword) {{ password: "krotchpotato", password_confirmation: "krotchpotato" }}

    it "removes the key :old_password from the supplied hash" do
      remove_old_password_key_from_hash(user).should == user_wo_oldpassword
    end

    it "returns the supplied hash if :old_password is not found" do
      remove_old_password_key_from_hash(user_wo_oldpassword).should == user_wo_oldpassword
    end
  end
end
