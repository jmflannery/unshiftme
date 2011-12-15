require 'spec_helper'

describe "UserSelectDialogs", :type => :request do
  it "should display all signed in users", :js => true do
    user = Factory(:user)
    user = Factory(:user, :name => "Herman")
    visit signin_path
    fill_in "Name", :with => user.name
    fill_in "Password", :with => user.password
    click_button "Sign In"
    click_link "Users"
    pending("should display several online users")
  end
end
