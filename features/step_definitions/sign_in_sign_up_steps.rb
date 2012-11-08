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

Given /^I am registered user "(.*?)" with password "(.*?)"$/ do |name, passwd|
  @user = FactoryGirl.create(:user,
                             user_name: name,
                             password: passwd,
                             password_confirmation: passwd)
end

Given /^I am registered administrative user "(.*?)" with password "(.*?)"$/ do |name, passwd|
  @user = FactoryGirl.create(:user,
                             user_name: name,
                             admin: true,
                             password: passwd,
                             password_confirmation: passwd)
end

Given /^I am logged in at "(.*?)"$/ do |workstation|
  visit signin_path
  sleep 1
  fill_in "User name", :with => @user.user_name
  fill_in "Password", :with => @user.password
  check workstation
  click_button "Sign In"
end

When /^I check workstation "(.*?)"$/ do |workstation|
  check workstation
end

When /^I uncheck workstation "(.*?)"$/ do |workstation|
  uncheck workstation
end

Given /^I am on the sign in page$/ do
  visit signin_path
end

Given /^I am on the register page$/ do
  visit register_path
end

Then /^I should see that registration was successful$/ do
  page.should have_content("Registration was successful! Sign in now to access Messenger.")
end

Then /^I should see that workstation "(.*?)" is checked$/ do |workstation_abrev|
  find("input##{workstation_abrev}").should be_checked
end

Then /^I should see that workstation "(.*?)" is not checked$/ do |workstation_abrev|
  find("input##{workstation_abrev}").should_not be_checked
end

Then /^I should see the sign in page$/ do
  sleep 1
  page.should have_content("Sign in")
end

Then /^I should see the register page$/ do
  page.should have_content("Register")
end

Then /^I should see my user home page$/ do
  page.should have_content(@user.user_name)
end

Then /^I should not be working any workstations$/ do
  Workstation.all.each { |workstation| workstation.user_id.should_not == @user.id }
end
