Given /^I am not a registered user$/ do
  @user = FactoryGirl.build(:user)
end

Given /^I am a registered user$/ do
  @user = FactoryGirl.create(:user)
end

Given /^I am on the sign in page$/ do
  visit signin_path
end

When /^I fill in "(.*?)" with "(.*?)"$/ do |arg1, arg2|
  fill_in "User name", with: @user.user_name
end

When /^I fill in password with "(.*?)"$/ do |arg1|
  fill_in "Password", with: @user.password
end

When /^I press "(.*?)"$/ do |arg1|
  click_button "Sign In"
end

Then /^I should see the sign in page$/ do
  page.should have_content("Sign in")
end

Then /^I should see my user home page$/ do
  page.should have_content(@user.first_name)
end

