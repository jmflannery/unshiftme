require 'spec_helper'

describe "User Selection", :js => true do

  before(:each) do
    @user = Factory(:user)
    @title = "Available Users"
    visit signin_path
    fill_in "Name", :with => @user.name
    fill_in "Password", :with => @user.password
    click_button "Sign In" 
  end

  describe "with other users online" do

    before(:each) do
      user1 = integration_test_sign_in(Factory(:user, :name => "Fred", :full_name => "Fred Mertz", 
                   :password => "qwerty", :password_confirmation => "qwerty"))
      user2 = integration_test_sign_in(Factory(:user, :name => "Jimmy", :full_name => "Jimmy McGee", 
                   :password => "uiopas", :password_confirmation => "uiopas")) 
      @users = [user1, user2]
    end

    it "should appear with correct title and disappear when closed" do
      click_link "To:"
      page.should have_selector(".visible h3", text: @title)
      click_button "OK"
      page.should_not have_selector(".visible h3", text: @title)
    end

    it "should display all signed in users" do
      click_link "To:"
      @users.each do |u|
        page.should have_selector(".visible li.online_user", text: u.full_name)
      end
    end

    it "should not display the current user" do
      click_link "To:"
      page.should_not have_selector(".visible li.online_user", text: @user.full_name)
    end

    it "should display all selected recipients on the user's page" do
      click_link "To:"
      click_button "OK"
      @users.each do |u|
        page.should have_selector("ul.recipient li", text: u.name)
      end
    end
  end

  describe "with no other users online" do

    it "should display a message if there are no online users" do
      click_link "To:"
      page.should have_selector(".visible li", text: "Nobody's at the party!")
    end
  end
end
