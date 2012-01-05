require 'spec_helper'

describe "User Selection", :js => true do

  before(:each) do
    @user1 = integration_test_sign_in(Factory(:user, :name => "Fred", :full_name => "Fred Mertz", 
                   :password => "qwerty", :password_confirmation => "qwerty"))
    @user2 = integration_test_sign_in(Factory(:user, :name => "Jimmy", :full_name => "Jimmy McGee", 
                   :password => "uiopas", :password_confirmation => "uiopas")) 
    @users = [@user1, @user2]
    @dialog_title = "Select fuckin Users.."
    @user = Factory(:user)
    visit signin_path
    fill_in "Name", :with => @user.name
    fill_in "Password", :with => @user.password
    click_button "Sign In"
    click_link "To:"
  end

  it "should display all selected recipients on the user's page" do
    click_button "OK"
    @users.each do |u|
      page.should have_text(u.name)
    end
  end

  describe "Dialog" do
    it "should pop up with correct title and disappear when closed" do
      page.should have_text(@dialog_title)
      click_button "OK"
      page.should_not have_text(@dialog_title) 
    end

    it "should display all signed in users" do
      @users.each do |u|
        page.should have_selector("label.a_user", :text => u.full_name)
      end 
    end

    it "should not display the current user" do
      page.should_not have_selector("label.a_user", :text => @user.full_name)
    end
  end
end
