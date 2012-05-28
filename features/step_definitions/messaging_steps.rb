When /^I go to the messaging page$/ do
end

Then /^I should not see recieved message "(.*?)" from desk "(.*?)" user "(.*?)"$/ do |message_content, desk_abrev, user_name|
  page.should_not have_selector(".message_sender p", text: "#{desk_abrev} (#{user_name})")
  page.should_not have_content message_content
end

Then /^I should see my message "(.*?)" from desk "(.*?)" user "(.*?)"$/ do |message_content, desk_abrev, user_name|
  page.should have_selector(".message_sender p", text: "#{desk_abrev} (#{user_name})")
  page.should have_selector("li.message.owner", text: @message)
end

Then /^I should see recieved message "(.*?)" from desk "(.*?)" user "(.*?)"$/ do |message_content, desk_abrev, user_name|
  page.should have_selector(".message_sender p", text: "#{desk_abrev} (#{user_name})")
  page.should have_selector("li.message.recieved", text: message_content)
end

Then /^I should nothing in the "(.*?)" text field$/ do |textfield_id|
  find_field(textfield_id).value.should be_blank
end

Given /^I click on the recieved message$/ do
  find("li.message.recieved.unread").click
end

Then /^I should see desk "(.*?)" user "(.*?)" read this$/ do |desk_abrev, user_name|
  page.should have_content("#{desk_abrev} (#{user_name}) read this.")
end

Then /^I should see a button for each desk indicating that I am not messaging that desk$/ do
  @test_records[:desk].each do |desk|
    page.should have_selector("##{desk.abrev}.recipient_desk.off")
  end
end

Then /^I should see a button for each desk indicating that I am not messaging that desk excluding my own desk "(.*?)"$/ do |desk_abrev|
  @test_records[:desk].each do |desk|
    if desk.abrev == desk_abrev
      page.should have_selector("##{desk.abrev}.recipient_desk.mine")
    else
      page.should have_selector("##{desk.abrev}.recipient_desk.off")
    end
  end
end

When /^I click on each button$/ do
  @test_records[:desk].each do |desk|
    find("##{desk.abrev}").click
  end
end

When /^I click "(.*?)"$/ do |desk_abrev|
  find("##{desk_abrev}").click
end

Then /^I should see that I am at "(.*?)"$/ do |desk|
  page.should have_selector("##{desk}.recipient_desk.mine")
end

Then /^I should see each button indicate that I am messaging that desk excluding my own desk "(.*?)"$/ do |desk_abrev|
  @test_records[:desk].each do |desk|
    if desk.abrev == desk_abrev
      page.should have_selector("##{desk.abrev}.recipient_desk.mine")
    else
      page.should have_selector("##{desk.abrev}.recipient_desk.on")
    end
  end
end

Then /^I should see that I am messaging "(.*?)"$/ do |desk|
  page.should have_selector("##{desk}.recipient_desk.on")
end

Then /^I should see that I am not messaging "(.*?)"$/ do |desk|
  page.should_not have_selector("##{desk}.recipient_desk.on")
end

Then /^I should see each button indicate that I am not messaging that desk excluding my own desk "(.*?)"$/ do |desk_abrev|
  @test_records[:desk].each do |desk|
    if desk.abrev == desk_abrev
      page.should have_selector("##{desk.abrev}.recipient_desk.mine")
    else
      page.should have_selector("##{desk.abrev}.recipient_desk.off")
    end
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
