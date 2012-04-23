require 'spec_helper'

describe "User Selection", :js => true do

  before(:each) do
    @title = "Available Users"
    @add_users_button_text = "Add Available Users"
    @user = FactoryGirl.create(:user)
    visit signin_path
    fill_in "User name", :with => @user.user_name
    fill_in "Password", :with => @user.password
    click_button "Sign In" 
  end

  describe "with other users online" do

    before(:each) do
      @users = []
      5.times do |n|
        usr = integration_test_sign_in(FactoryGirl.create(:user1, user_name: "User-#{n}", email: "user#{n}@example.com"))
        @users << usr
      end
    end

    it "should appear with correct title and disappear when closed" do
      click_link @add_users_button_text
      page.should have_content("Available Users:")
      find("#hide_button").click
      page.should_not have_content("Available Users:")
    end

    it "should display all online users, except for the current user" do
      click_link @add_users_button_text
      @users.each do |u|
        page.should have_selector(".available_user", text: u.user_name)
      end
      page.should_not have_selector(".available_user", text: @user.user_name)
    end

    it "should display all selected recipients on the user's page" do
      click_link @add_users_button_text
      @users.each do |user|
        click_link user.user_name
      end

      find("#hide_button").click

      @users.each do |user|
        page.should have_selector(".recipient_user", text: user.user_name)
      end
    end
  end

  describe "with no other users online" do

    it "should display a message if there are no online users" do
      click_link @add_users_button_text
      page.should have_content("Available Users: Nobody!")
    end
  end
end
