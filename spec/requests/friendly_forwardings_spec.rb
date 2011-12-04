require 'spec_helper'
require 'sessions_helper'

describe "FriendlyForwardings", :type => :request do

  it "should forward to the requested page after sign in" do
    user = Factory(:user)
    visit edit_user_path(user)
    #save_and_open_page
    #response.should redirect_to signin_path
    page.should have_content("Sign In")
    # Test follows redirect to the sign in page
    # follow_redirect!
    fill_in "Name", :with => user.name
    fill_in "Password", :with => user.password
    click_button "Sign In"
    # # Test follows redirect to users/edit
    # response.should render_template(edit_user_path(user))
    # response.should render_template('users/edit')
    page.should have_content("Edit user")
  end
end
