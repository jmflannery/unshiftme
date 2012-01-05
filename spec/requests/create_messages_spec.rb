require 'spec_helper'

describe "CreateMessages" do
  
  describe "after sending a message", :js => true do
    
    before(:each) do
      @user = Factory(:user)
      visit signin_path
      fill_in "Name", :with => @user.name
      fill_in "Password", :with  => @user.password
      click_button "Sign In"
      @message = "this is a message, wassup"
      fill_in "message_content", :with => @message
      click_button "Send"
    end

    it "the message should appear on the senders screen" do
      page.should have_content("#{@user.name}: #{@message}") 
    end
    
    it "should clear the message input text field" do
      find_field("message_content").value.should be_blank
    end
    
  end
end
