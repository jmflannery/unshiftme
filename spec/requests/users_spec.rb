require 'spec_helper'

describe "Users" do

  describe "signup" do

    describe "failure" do

      it "should not make a new user" do
        lambda do
          visit signup_path
          fill_in "First name", with: ""
          fill_in "Middle initial", with: ""
          fill_in "Last name", with: ""
          fill_in "User name", with: ""
          fill_in "Email", with: ""
          fill_in "password", with: ""
          fill_in "conformation", with: ""
          click_button "Sign Up"
          page.should have_content("Sign up")
        end.should_not change(User, :count)
      end
    end

    describe "success" do

      it "should make a new user" do
        lambda do
          visit signup_path
          fill_in "First name", with: "Derick"
          fill_in "Middle initial", with: "X"
          fill_in "Last name", with: "Jeter"
          fill_in "User name", with: "djeter"
          fill_in "Email", with: "user@example.com"
          fill_in "password", with: "foobar"
          fill_in "conformation", with: "foobar"
          click_button "Sign Up"
          page.should have_content("Derick X. Jeter")
        end.should change(User, :count).by(1)
      end
    end
  end

  describe "sign in/out" do

  describe "failure" do
      it "should not sign a user in" do
        visit signin_path
        fill_in "User name",     :with => ""
        fill_in "Password", :with => ""
        click_button "Sign In"
        page.should have_content("Sign in")
      end
    end

    describe "success" do
      it "should sign a user in and out" do
        user = FactoryGirl.create(:user)
        visit signin_path
        fill_in "User name", :with => user.user_name
        fill_in "Password", :with => user.password
        click_button "Sign In"
        page.should have_content(user.first_name)
        click_link "Sign out"
        page.should have_content("Sign in")
      end
    end
  end
end
