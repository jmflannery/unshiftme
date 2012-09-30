Given /^the following messages$/ do |table|
  @messages = []
  table.hashes.each do |hash|
    user = @test_records[:user].select { |user| user.user_name == hash["user"] }.first
    message = user.messages.new
    message.content = hash["content"] if hash.has_key?("content")
    message.id = hash["id"] if hash.has_key?("id")
    sender = message.sender_workstations.new
    sender.workstation = Workstation.find_by_abrev(hash["from"]) if hash.has_key?("from")
    sender.save
    to_user = hash.has_key?("to_user") ? hash["to_user"] : ""
    to_workstation = hash.has_key?("to_workstation") ? hash["to_workstation"] : ""
    receiver = message.receivers.new
    receiver.workstation = Workstation.find_by_abrev(to_workstation) unless to_workstation.blank?
    receiver.user = User.find_by_user_name(to_user) unless to_user.blank?
    receiver.save
    if hash.has_key?("read") and hash["read"] == "t"
      message.read_by = {to_user => to_workstation}
    end
    if hash.has_key?("created_at")
      if hash["created_at"].include?("ago")
        number, period, ago = hash["created_at"].split(".")
        num = number.to_i
        message.created_at = num.send(period).ago
      else
        message.created_at = Time.zone.parse("#{hash["created_at"]}")
      end
    end
    message.save
    @messages << message
  end
end

When /^I go to the messaging page$/ do
end

Then /^I should not see recieved message (\d+) "(.*?)"$/ do |id, content|
  page.should_not have_selector("li.message.msg-#{id}.recieved.read")
end

Then /^I should not see unread recieved message (\d+) "(.*?)"$/ do |id, content|
  page.should_not have_selector("li.message.msg-#{id}.recieved.unread")
end

Then /^I should see sent message (\d+) "(.*?)" from workstation "(.*?)" user "(.*?)" one time$/ do |id, content, workstation_abrev, user_name|
  selector = "li.message.msg-#{id}.owner" 
  page.should have_selector(selector, count: 1)
  within(selector) do
    page.should have_selector(".content p", text: content)
    page.should have_selector(".sender p", text: "#{user_name}@#{workstation_abrev}")
  end
end

Then /^I should see recieved message (\d+) "(.*?)" from workstation "(.*?)" user "(.*?)" one time$/ do |id, content, workstation_abrev, user_name|
  selector = "li.message.msg-#{id}.recieved.read" 
  page.should have_selector(selector, count: 1)
  within(selector) do
    page.should have_selector(".sender p", text: "#{user_name}@#{workstation_abrev}")
    page.should have_selector(".content p", text: content)
  end
end

Then /^I should see unread recieved message (\d+) "(.*?)" from workstation "(.*?)" user "(.*?)" one time$/ do |id, content, workstation_abrev, user_name|
  selector = "li.message.msg-#{id}.recieved.unread" 
  page.should have_selector(selector, count: 1)
  within(selector) do
    page.should have_selector(".sender p", text: "#{user_name}@#{workstation_abrev}")
    page.should have_selector(".content p", text: content)
  end
end

Then /^I should see workstation "(.*?)" user "(.*?)" read message (\d+)$/ do |workstation_abrev, user_name, id|
  within("li.message.msg-#{id}") do
    page.should have_content("#{user_name}@#{workstation_abrev} read this.")
  end
end

Then /^I should not see workstation "(.*?)" user "(.*?)" read message (\d+)$/ do |workstation_abrev, user_name, id|
  within("li.message.msg-#{id}") do
    page.should_not have_content("#{user_name}@#{workstation_abrev} read this.")
  end
end

Then /^I should not see recieved message "(.*?)" from workstation "(.*?)" user "(.*?)"$/ do |message_content, workstation_abrev, user_name|
  page.should_not have_selector(".message_sender p", text: "#{workstation_abrev} (#{user_name})")
  page.should_not have_content message_content
end

Then /^I should see sent message "(.*?)" from workstation "(.*?)" user "(.*?)" one time$/ do |message_content, workstation_abrev, user_name|
  within("li.message.owner") do
    page.should have_selector(".sender p", text: "#{user_name}@#{workstation_abrev}")
    page.should have_selector(".content p", text: @message)
  end
end

Then /^I should see recieved message "(.*?)" from workstation "(.*?)" user "(.*?)" one time$/ do |message_content, workstation_abrev, user_name|
  within("li.message.recieved.unread") do
    page.should have_selector(".sender p", text: "#{user_name}@#{workstation_abrev}", count: 1)
    page.should have_selector(".content p", text: message_content, count: 1)
  end
end

Then /^I should see workstation "(.*?)" user "(.*?)" read this$/ do |workstation_abrev, user_name|
  page.should have_content("#{user_name}@#{workstation_abrev} read this.")
end

Then /^I should see that received message (\d+) was read$/ do |message_id|
  page.should have_selector("li.message.msg-#{message_id}.recieved.read")
end

Then /^I should nothing in the "(.*?)" text field$/ do |textfield_id|
  find_field(textfield_id).value.should be_blank
end

Given /^I click on the recieved message$/ do
  find("li.message.recieved.unread").click
end

When /^I click on each button$/ do
  @test_records[:workstation].each do |workstation|
    find("##{workstation.abrev}").click
  end
end

When /^I click Message "(.*?)"$/ do |action|
  find(".recipient_workstation.#{action}").click
end

When /^I click "(.*?)"$/ do |workstations|
  workstations.split(",").each { |workstation| find("##{workstation}").click }
end

Then /^I should see that I am at "(.*?)"$/ do |workstation|
  page.should have_selector("##{workstation}.recipient_workstation.mine")
end

Then /^I should see each Workstation Toggle Button indicate that I am messaging that workstation, excluding my own workstation "(.*?)"$/ do |workstation_abrev|
  @test_records[:workstation].each do |workstation|
    if workstation.abrev == workstation_abrev
      page.should have_selector("##{workstation.abrev}.recipient_workstation.mine")
      page.should_not have_selector("##{workstation.abrev}.on")
    else
      page.should have_selector("##{workstation.abrev}.recipient_workstation.on")
    end
  end
end

Then /^I should see each Workstation Toggle Button indicate that I am not messaging that workstation, excluding my own workstation "(.*?)"$/ do |workstation_abrev|
  @test_records[:workstation].each do |workstation|
    if workstation.abrev == workstation_abrev
      page.should have_selector("##{workstation.abrev}.recipient_workstation.mine")
    else
      page.should have_selector("##{workstation.abrev}.recipient_workstation.off")
    end
  end
end

Then /^I should see that I am messaging "(.*?)"$/ do |workstations|
  workstations.split(",").each { |workstation| page.should have_selector("##{workstation}.recipient_workstation.on") }
end

Then /^I should see that I am not messaging "(.*?)"$/ do |workstations|
  workstations.split(",").each { |workstation| page.should_not have_selector("##{workstation}.recipient_workstation.on") }
end

Then /^I should see that "(.*?)" is at "(.*?)" workstation$/ do |user, workstations|
  workstations.split(",").each do |workstation|
    if user == "nobody"
      page.should have_selector("##{workstation}", text: "(vacant)")
    else
      page.should have_selector("##{workstation}", text: "(#{user})")
    end
  end
end

Given /^I log out$/ do
  click_link "Sign out"
end

