When /^I send "(.*?)" to "(.*?)"$/ do |file_name, workstation|
  find("##{workstation}").click
  click_link 'attach_button'
  attach_file("attachment_payload", "/home/jack/work/amtrak_messenger/spec/fixtures/files/#{file_name}")
  click_button "Upload"
end

Then /^I should see the files page$/ do
  page.should have_css("title", content: "Files") 
end

