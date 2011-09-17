require 'spec_helper'

describe "FriendlyForwardings" do

  it "should forward to the requested page after sign in" do
    user = Factory(:user)
    visit edit_user_path(user)
    # Test follows redirect to the sign in page
    fill_in :name, :with => user.name
    fill_in :password, :with => user.password
    click_button
    # Test follows redirect to users/edit
    response.should render_template('users/edit')
  end

end

