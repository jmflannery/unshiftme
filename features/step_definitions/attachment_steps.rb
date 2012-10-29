When /^I click on the upload attachment icon$/ do
  find('img#attach_button').click
  page.execute_script("$('form#new_attach45ment11').submit()")
end

Then /^I should see the attachement upload section$/ do
  page.should have_css("#upload_section")
end

When /^I attach file "(.*?)"$/ do |file_name|
  attach_file("attachment_payload", "/home/jack/work/amtrak_messenger/spec/fixtures/files/#{file_name}")
end

