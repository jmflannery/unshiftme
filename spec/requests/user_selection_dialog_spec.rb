require 'spec_helper'

describe "UserSelectionDialog", :type => :request do
  it "should display all signed in users", :js => true do

    user1 = Factory(:user, :name => "Fred", :full_name => "Fred Mertz", 
                   :password => "qwerty", :password_confirmation => "qwerty")
    user2 = Factory(:user, :name => "Jimmy", :full_name => "Jimmy McGee", 
                   :password => "uiopas", :password_confirmation => "uiopas")

    integration_test_sign_in(user1)
    integration_test_sign_in(user2)
    user3 = Factory(:user)
    users = [user1, user2, user3]
    visit signin_path
    page.should_not have_text("Select fuckin Users..")
    fill_in "Name", :with => user3.name
    fill_in "Password", :with => user3.password
    click_button "Sign In"  
    click_link "To:"
    page.should have_text("Select fuckin Users..")
    users.each do |u|
      page.should have_text(u.full_name)
    end
    click_button "OK"
    page.should_not have_text("Select fuckin Users..")
  end
end
