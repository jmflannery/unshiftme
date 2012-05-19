Given /^I am in (.*) browser$/ do |name|
  Capybara.session_name = name
end

Given /^the following (.+) records?$/ do |factory, table|
  records = []
  table.hashes.each do |hash|
    records << FactoryGirl.create(factory, hash)
  end
  @test_records ||= Hash.new()
  @test_records[factory.to_sym] = records unless @test_records.has_key?(factory.to_sym)
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

When /^I press the "(.*?)" key$/ do |key|
  find_field('message_content').native.send_key(key.to_sym)
end

Then /^I should not see recieved message "(.*?)"$/ do |message_content|
  page.should_not have_content message_content
end

Then /^I should see my message "(.*?)"$/ do |message_content|
  page.should have_selector("li.message.owner", text: @message)
end

Then /^I should see recieved message "(.*?)"$/ do |message_content|
  page.should have_selector("li.message.recieved", text: message_content)
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

Given /^I click on the recieved message$/ do
  find("li.message.recieved.unread").click
end

Then /^I should see "(.*?)" read this$/ do |user|
  page.should have_content("#{user} read this.")
end

Then /^I should see a button for each desk indicating that I am not messaging that desk$/ do
  @test_records[:desk].each do |desk|
    page.should have_selector("##{desk.abrev}", ".recipient_desk")
  end
end

When /^I click on each button$/ do
  @test_records[:desk].each do |desk|
    find("##{desk.abrev}").click
  end
end

Then /^I should see each button indicate that I am messaging that desk$/ do
  @test_records[:desk].each do |desk|
    page.should have_selector("##{desk.abrev}", ".recipient_desk.on")
  end
end

Then /^I should see each button indicate that I am not messaging that desk$/ do
  @test_records[:desk].each do |desk|
    page.should have_selector("##{desk.abrev}", ".recipient_desk.off")
  end
end

Then /^I should see that "(.*?)" is at "(.*?)" desk$/ do |user, desk|
  if user == "nobody"
    page.should have_selector("##{desk}", text: "(vacant)")
  else
    page.should have_selector("##{desk}", text: "(#{user})")
  end
end

Given /^I log out$/ do
  click_link "Sign out"
end
