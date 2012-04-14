require 'spec_helper'

describe "CreateMessages" do
  
  describe "after sending a message" do
    
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
    
    it "the message should appear on the senders screen", js: true do
      page.should have_selector(".message", text: @message)
    end
    
    it "should clear the message input text field", js: true do
      find_field("message_content").value.should be_blank
    end
  end
end
