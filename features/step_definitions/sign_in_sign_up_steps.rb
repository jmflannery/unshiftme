Given /^I am not a registered user$/ do
  @user = FactoryGirl.build(:user,
                            user_name: "fred",
                            password: "secret",
                            password_confirmation: "secret")
end

Given /^I am a registered user$/ do
  @user = FactoryGirl.create(:user,
                             user_name: "fred",
                             password: "secret",
                             password_confirmation: "secret")
end

Given /^I am on the sign in page$/ do
  visit signin_path
end

Given /^I am on the sign up page$/ do
  visit signup_path
end

Then /^I should see the sign in page$/ do
  page.should have_content("Sign in")
end

Then /^I should see the sign up page$/ do
  page.should have_content("Sign up")
end

Then /^I should see my user home page$/ do
  page.should have_content(@user.user_name)
end
