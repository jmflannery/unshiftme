Given /^I am not a registered user$/ do
  @user = FactoryGirl.build(:user,
                            user_name: "fsavage",
                            password: "jjjjjj",
                            password_confirmation: "jjjjjj")
end

Given /^I am a registered user$/ do
  @user = FactoryGirl.create(:user,
                             user_name: "fsavage",
                             password: "jjjjjj",
                             password_confirmation: "jjjjjj")
end

Given /^I am on the sign in page$/ do
  visit signin_path
end

Given /^I am on the sign up page$/ do
  visit signup_path
end

When /^I fill in "(.*?)" with "(.*?)"$/ do |arg1, arg2|
  fill_in arg1, with: arg2
end

When /^I press "(.*?)"$/ do |arg1|
  click_button arg1
end

Then /^I should see the sign in page$/ do
  page.should have_content("Sign in")
end

Then /^I should see my user home page$/ do
  page.should have_content(@user.user_name)
end

Then /^I should see the sign up page$/ do
  page.should have_content("Sign up")
end
