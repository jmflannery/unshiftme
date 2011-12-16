require 'spec_helper'

describe "Users" do

  describe "signup", :type => :request do

    describe "failure" do

      it "should not make a new user" do
        lambda do
          visit signup_path
          fill_in "Name",         :with => ""
          fill_in "Full name",    :with => ""
          fill_in "Email",        :with => ""
          fill_in "Password",     :with => ""
          fill_in "Password confirmation", :with => ""
          click_button "Sign Up"
          #response.should render_template('users/new')
          #current_path.should == signup_path
          page.should have_content("Sign Up")
        end.should_not change(User, :count)
      end
    end

    describe "success" do

      it "should make a new user" do
        lambda do
          visit signup_path
          fill_in "Name",         :with => "DJ"
          fill_in "Full name",    :with => "Derick Jeter"
          fill_in "Email",        :with => "user@example.com"
          fill_in "Password",     :with => "foobar"
          fill_in "Password confirmation", :with => "foobar"
          click_button "Sign Up"
          #response.should have_selector("div.flash.success",
           #                             :content => "Welcome")
          #response.should render_template('users/show')
          page.should have_content("Derick Jeter")
        end.should change(User, :count).by(1)
      end
    end
  end

  describe "sign in/out" do

  describe "failure" do
      it "should not sign a user in" do
        visit signin_path
        fill_in "Name",     :with => ""
        fill_in "Password", :with => ""
        click_button "Sign In"
        #response.should have_selector("div.flash.error", :content => "Invalid")
        #controller.should_not be_signed_in
        page.should have_content("Sign In")
      end
    end

    describe "success" do
      it "should sign a user in and out" do
        user = Factory(:user)
        visit signin_path
        fill_in "Name", :with => user.name
        fill_in "Password", :with => user.password
        click_button "Sign In"
        page.should have_content(user.full_name)
        click_link "Sign out"
        page.should have_content("Chatty Pants")
        #controller.should_not be_signed_in
      end
    end
  end
end

