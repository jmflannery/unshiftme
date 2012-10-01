When /^I click on the upload attachment icon$/ do
  click_link 'attach_button'
end

Then /^I should see the attachement upload section$/ do
  page.should have_css("#upload_section")
end

When /^I attach file "(.*?)"$/ do |file_name|
  attach_file("attachment_payload", "spec/fixtures/files/#{file_name}")
end

