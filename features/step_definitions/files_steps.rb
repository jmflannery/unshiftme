When /^I send "(.*?)" to "(.*?)"$/ do |file_name, workstation|
  find("##{workstation}").click
  find('#attach_button').click
  attach_file("attachment[payload]", "/Users/jack/code/private/amtrak_messenger/spec/fixtures/files/#{file_name}")
end

Then /^I should see the files page$/ do
  page.should have_css("#files_page") 
end

Then(/^I should not see a link to "(.*?)"$/) do |file_name|
  expect(page).not_to have_content file_name
end

Then(/^I should see a link to "(.*?)"$/) do |file_name|
  expect(page).to have_content file_name
end

Then(/^I should not see any files$/) do
  within("ul#files_list") do
    expect(page).not_to have_css("li.file")
  end
end
