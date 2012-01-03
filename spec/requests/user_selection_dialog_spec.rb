require 'spec_helper'

describe "User Selection", :type => :request do

  before(:each) do
    @user1 = integration_test_sign_in(Factory(:user, :name => "Fred", :full_name => "Fred Mertz", 
                   :password => "qwerty", :password_confirmation => "qwerty"))
    @user2 = integration_test_sign_in(Factory(:user, :name => "Jimmy", :full_name => "Jimmy McGee", 
                   :password => "uiopas", :password_confirmation => "uiopas")) 
    @users = [@user1, @user2]
    @dialog_title = "Select fuckin Users.."
  end

  describe "Dialog" do
    it "should display all signed in users", :js => true do
      user = Factory(:user)
      visit signin_path
      page.should_not have_text(@dialog_title)
      fill_in "Name", :with => user.name
      fill_in "Password", :with => user.password
      click_button "Sign In"  
      click_link "To:"
      page.should have_text(@dialog_title)
      @users.each do |u|
        page.should have_text(u.full_name)
      end
      click_button "OK"
      page.should_not have_text(@dialog_title)
    end

    it "should not display the current user", :js => true do
      user = Factory(:user)
      visit signin_path
      fill_in "Name", :with => user.name
      fill_in "Password", :with => user.password
      click_button "Sign In"
      click_link "To:"
      page.should_not have_selector("label.a_user", :text => user.full_name)
    end
  end

  it "should display all selected recipients on the user's page", :js => true do
    user = Factory(:user)
    visit signin_path
    fill_in "Name", :with => user.name
    fill_in "Password", :with => user.password
    click_button "Sign In"  
    click_link "To:"
    click_button "OK"
    page.should_not have_text(@dialog_title)
    @users.each do |u|
      page.should have_text(u.name)
    end
  end
end
