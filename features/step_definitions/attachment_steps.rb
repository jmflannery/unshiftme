When /^I click on the upload attachment icon$/ do
  find('#attach_button').click
end

Then /^I should see the attachement upload section$/ do
  page.should have_css("#upload_section")
end

When /^I attach file "(.*?)"$/ do |file_name|
  attach_file("attachment_payload", "/home/jack/work/amtrak_messenger/spec/fixtures/files/#{file_name}")
end

