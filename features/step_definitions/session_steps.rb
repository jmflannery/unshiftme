Given /^I am in (.*) browser$/ do |name|
  Capybara.session_name = name
end

Given /^the following (.+) records?$/ do |factory, table|
  table.hashes.each do |hash|
    FactoryGirl.create(factory, hash)
  end
end

Given /^I am logged in as "([^\"]*)" with password "([^\"]*)" at "([^\"]*)"$/ do |username, password, desk|
  unless username.blank?
    visit signin_path
    fill_in "User name", :with => username
    fill_in "Password", :with => password
    check desk
    click_button "Sign In"
  end
end

When /^I go to the messaging page$/ do
end

Then /^I should not see "(.*?)"$/ do |message_content|
  page.should_not have_content message_content
end

When /^I press the "(.*?)" key$/ do |key|
  find_field('message_content').native.send_key(key.to_sym)
end

Then /^I should see "(.*?)"$/ do |message_content|
  page.should have_content message_content
  #page.should have_selector("li.message.recieved", text: message_content)
end

When /^I click "(.*?)"$/ do |desk_abrev|
  find("##{desk_abrev}").click
end

When /^I wait (\d+) seconds?$/ do |seconds|
  sleep seconds.to_i
end

Then /^I should nothing in the "(.*?)" text field$/ do |textfield_id|
  find_field(textfield_id).value.should be_blank
end
