Then /^I should see user records for "(.*?)"$/ do |user_names|
  users = user_name.split(",")
  users.each do |user_name|
    within("li.user_name") do
      page.should have_selector("p", text: user_name)
    end
  end
end

Then /^I should see that user "(.*?)" is an admin user$/ do |arg1|
  pending # express the regexp above with the code you wish you had
end

Then /^I should see that users "(.*?)" are not admin users$/ do |arg1|
  pending # express the regexp above with the code you wish you had
end
