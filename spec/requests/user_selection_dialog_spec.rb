require 'spec_helper'

describe "User Selection Dialog", :js => true do

  before(:each) do
    @user = Factory(:user)
    @dialog_title = "Who would you like to message?"
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

    it "should pop up with correct title and disappear when closed" do
      pending "capybara / selenium bug" #do
        click_link "To:"
        page.should have_text(@dialog_title)
        #page.should have_content(@dialog_title)
        click_button "OK"
        page.should_not have_content(@dialog_title) 
      #end
    end

    it "should display all signed in users" do
      pending "capybara / selenium bug" #do
        click_link "To:"
        @users.each do |u|
          page.should have_selector("label.a_user", :text => u.full_name)
        end
      #end 
    end

    it "should not display the current user" do
      pending "capybara / selenium bug" #do
        click_link "To:"
        page.should_not have_selector("label.a_user", :text => @user.full_name)
      #end
    end

    it "should display all selected recipients on the user's page" do
      pending "capybara / selenium bug" #do
        click_link "To:"
        click_button "OK"
        @users.each do |u|
          page.should have_text(u.name)
          #page.should have_content(u.name)
        end
      #end
    end
  end

  describe "with no other users online" do

    it "should display a message if there are no online users" do
      pending "capybara / selenium bug" #do
        click_link "To:"
        page.should have_text("Nobody's at the party!")
        #page.should have_content("Nobody's at the party!")
      #end
    end
  end
end
