Given /^the following messages$/ do |table|
  @messages = []
  table.hashes.each do |hash|
    user = @test_records[:user].select { |user| user.user_name == hash["user"] }.first
    message = user.messages.new
    message.content = hash["content"] if hash.has_key?("content")
    message.id = hash["id"] if hash.has_key?("id")
    message.sent = [hash["from"]] if hash.has_key?("from")
    to_user = hash.has_key?("to_user") ? hash["to_user"] : ""
    to_desk = hash.has_key?("to_desk") ? hash["to_desk"] : ""
    message.recievers = {to_desk => to_user}
    if hash.has_key?("read") and hash["read"] == "t"
      message.read_by = {to_user => to_desk}
    end
    message.created_at = DateTime.parse("#{hash["created_at"]}-0500") if hash["created_at"]
    message.save
    @messages << message
  end
end

When /^I go to the messaging page$/ do
end

Then /^I should not see recieved message (\d+) "(.*?)" from desk "(.*?)" user "(.*?)"$/ do |id, content, desk_abrev, user_name|
  page.should_not have_selector("li.message.msg-#{id}.recieved.read")
end

Then /^I should see sent message (\d+) "(.*?)" from desk "(.*?)" user "(.*?)" one time$/ do |id, content, desk_abrev, user_name|
  selector = "li.message.msg-#{id}.owner" 
  page.should have_selector(selector, count: 1)
  within(selector) do
    page.should have_content(content)
    page.should have_selector(".message_sender p", text: "#{user_name}@#{desk_abrev}")
  end
end

Then /^I should see recieved message (\d+) "(.*?)" from desk "(.*?)" user "(.*?)" one time$/ do |id, content, desk_abrev, user_name|
  save_and_open_page
  selector = "li.message.msg-#{id}.recieved.read" 
  page.should have_selector(selector, count: 1)
  within(selector) do
    page.should have_content(content)
    page.should have_selector(".message_sender p", text: "#{user_name}@#{desk_abrev}")
  end
end

Then /^I should not see recieved message "(.*?)" from desk "(.*?)" user "(.*?)"$/ do |message_content, desk_abrev, user_name|
  page.should_not have_selector(".message_sender p", text: "#{desk_abrev} (#{user_name})")
  page.should_not have_content message_content
end

Then /^I should see sent message "(.*?)" from desk "(.*?)" user "(.*?)" one time$/ do |message_content, desk_abrev, user_name|
  page.should have_selector(".message_sender p", text: "#{user_name}@#{desk_abrev}")
  page.should have_selector("li.message.owner", text: @message)
end

Then /^I should see recieved message "(.*?)" from desk "(.*?)" user "(.*?)" one time$/ do |message_content, desk_abrev, user_name|
  page.should have_selector(".message_sender p", text: "#{user_name}@#{desk_abrev}", count: 1)
  page.should have_selector("li.message.recieved", text: message_content, count: 1)
end

Then /^I should nothing in the "(.*?)" text field$/ do |textfield_id|
  find_field(textfield_id).value.should be_blank
end

Given /^I click on the recieved message$/ do
  find("li.message.recieved.unread").click
end

Then /^I should see desk "(.*?)" user "(.*?)" read message (\d+)$/ do |desk_abrev, user_name, id|
  within("li.message.msg-#{id}") do
    page.should have_content("#{user_name}@#{desk_abrev} read this.")
  end
end

Then /^I should not see desk "(.*?)" user "(.*?)" read message (\d+)$/ do |desk_abrev, user_name, id|
  page.should_not have_selector("li.message.msg-#{id}")
end

Then /^I should see desk "(.*?)" user "(.*?)" read this$/ do |desk_abrev, user_name|
  page.should have_content("#{user_name}@#{desk_abrev} read this.")
end

When /^I click on each button$/ do
  @test_records[:desk].each do |desk|
    find("##{desk.abrev}").click
  end
end

When /^I click Message "(.*?)"$/ do |action|
  find(".recipient_desk.#{action}").click
end

When /^I click "(.*?)"$/ do |desks|
  desks.split(",").each { |desk| find("##{desk}").click }
end

Then /^I should see that I am at "(.*?)"$/ do |desk|
  page.should have_selector("##{desk}.recipient_desk.mine")
end

Then /^I should see each Desk Toggle Button indicate that I am messaging that desk, excluding my own desk "(.*?)"$/ do |desk_abrev|
  @test_records[:desk].each do |desk|
    if desk.abrev == desk_abrev
      page.should have_selector("##{desk.abrev}.recipient_desk.mine")
      page.should_not have_selector("##{desk.abrev}.on")
    else
      page.should have_selector("##{desk.abrev}.recipient_desk.on")
    end
  end
end

Then /^I should see each Desk Toggle Button indicate that I am not messaging that desk, excluding my own desk "(.*?)"$/ do |desk_abrev|
  @test_records[:desk].each do |desk|
    if desk.abrev == desk_abrev
      page.should have_selector("##{desk.abrev}.recipient_desk.mine")
    else
      page.should have_selector("##{desk.abrev}.recipient_desk.off")
    end
  end
end

Then /^I should see that I am messaging "(.*?)"$/ do |desks|
  desks.split(",").each { |desk| page.should have_selector("##{desk}.recipient_desk.on") }
end

Then /^I should see that I am not messaging "(.*?)"$/ do |desks|
  desks.split(",").each { |desk| page.should_not have_selector("##{desk}.recipient_desk.on") }
end

Then /^I should see that "(.*?)" is at "(.*?)" desk$/ do |user, desks|
  desks.split(",").each do |desk|
    if user == "nobody"
      page.should have_selector("##{desk}", text: "(vacant)")
    else
      page.should have_selector("##{desk}", text: "(#{user})")
    end
  end
end

Given /^I log out$/ do
  click_link "Sign out"
end

