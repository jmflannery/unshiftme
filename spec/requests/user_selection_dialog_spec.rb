require 'spec_helper'

describe "UserSelectonDialog", :type => :request do
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
    fill_in "Name", :with => user3.name
    fill_in "Password", :with => user3.password
    click_button "Sign In"
    click_link "To:"
    users.each do |u|
      page.should have_selector('li.a_user', :content => u.full_name) 
    end
  end
end
