require 'spec_helper'

describe "CreateMessages", :type => :request do
  
  describe "after sending a message", :js => true do
    
    it "the message should appear on the senders screen" do
      user = Factory(:user)
      visit signin_path
      fill_in "Name", :with => user.name
      fill_in "Password", :with  => user.password
      click_button "Sign In"
      #save_and_open_page
      m = "this is a message"
      fill_in "message_content", :with => m
      click_button "Send"
      page.should have_content("#{user.name}: #{m}")
      #page.should have_content(m)
    end
    
    it "should clear the message input text field" do
      user = Factory(:user)
      visit signin_path
      fill_in "Name", :with => user.name
      fill_in "Password", :with  => user.password
      click_button "Sign In"
      m = "this is a message"
      fill_in "message_content", :with => m
      click_button "Send"
      find_field("message_content").value.should be_blank
    end
    
  end
end
