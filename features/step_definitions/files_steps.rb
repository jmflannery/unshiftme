When /^I send "(.*?)" to "(.*?)"$/ do |file_name, workstation|
  find("##{workstation}").click
  find('#upload_button').click
  attach_file("attachment[payload]", "/Users/jack/code/private/amtrak_messenger/spec/fixtures/files/#{file_name}")
end

Then /^I should see the files page$/ do
  page.should have_css("title", content: "Files") 
end

