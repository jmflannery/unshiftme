require 'spec_helper'

describe "FriendlyForwardings" do

  it "should forward to the requested page after sign in" do
    user = Factory(:user)
    visit edit_user_path(user)
    response.should redirect_to signin_path
    # Test follows redirect to the sign in page
    #follow_redirect!
    fill_in :name, :with => user.name
    fill_in :password, :with => user.password
    click_button "Sign In"
    # Test follows redirect to users/edit
    #response.should render_template(edit_user_path(user))
    #page.should have_content("Edit user")
    response.should render_template('users/edit')
  end
end
