require 'spec_helper'
require 'sessions_helper'

describe "FriendlyForwardings" do

  it "should forward to the requested page after sign in" do
    user = FactoryGirl.create(:user)
    visit edit_user_path(user)
    page.should have_content("Sign in")
    # Test follows redirect to the sign in page
    fill_in "User name", :with => user.user_name
    fill_in "Password", :with => user.password
    click_button "Sign In"
    # Test follows redirect to users/edit
    page.should have_content("Edit user")
  end
end
