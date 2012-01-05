require 'spec_helper'
require 'sessions_helper'

describe "FriendlyForwardings" do

  it "should forward to the requested page after sign in" do
    user = Factory(:user)
    visit edit_user_path(user)
    page.should have_content("Sign In")
    # Test follows redirect to the sign in page
    fill_in "Name", :with => user.name
    fill_in "Password", :with => user.password
    click_button "Sign In"
    # Test follows redirect to users/edit
    page.should have_content("Edit user")
  end
end
