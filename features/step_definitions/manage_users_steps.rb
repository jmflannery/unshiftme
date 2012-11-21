Then /^I should see user records for "(.*?)"$/ do |user_names|
  user_names.split(",").each do |user_name|
    within("li.#{user_name}") do
      page.should have_content(user_name)
      page.should have_css("label", text: "Admin")
    end
  end
end

Then /^I should not see user records for "(.*?)"$/ do |user_names|
  user_names.split(",").each do |user_name|
    page.should_not have_css("li.#{user_name}")
  end
end

Then /^I should see that user "(.*?)" is an admin user$/ do |user_name|
  within("li.#{user_name}") do
    find("input#user_admin").should be_checked
  end
end

Then /^I should see that users "(.*?)" are admin users$/ do |user_names|
  user_names.split(",").each do |user_name|
    within("li.#{user_name}") do
      find("input#user_admin").should be_checked
    end
  end
end

Then /^I should see that users "(.*?)" are not admin users$/ do |user_names|
  user_names.split(",").each do |user_name|
    within("li.#{user_name}") do
      find("input#user_admin").should_not be_checked
    end
  end
end

When /^I click delete for User "(.*?)"$/ do |user_name|
  within("li.#{user_name}") do
    click_link "Delete"
  end
end

When /^I confirm that I want to delete "(.*?)"$/ do |user_name|
  within("li.#{user_name}") do
    click_button "Yes delete user #{user_name}"
  end
end

When /^I check admin for user "(.*?)"$/ do |user_name|
  within("li.#{user_name}") do
    check "Admin"
  end
end

When /^I uncheck admin for user "(.*?)"$/ do |user_name|
  within("li.#{user_name}") do
    uncheck "Admin"
  end
end

When /^I press Update for user "(.*?)"$/ do |user_name|
  within("li.#{user_name}") do
    click_button "Update"
  end
end
