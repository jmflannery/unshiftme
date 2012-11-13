Then /^I should see user records for "(.*?)"$/ do |user_names|
  user_names.split(",").each do |user_name|
    within("li.#{user_name}") do
      page.should have_content(user_name)
    end
  end
end

Then /^I should see that user "(.*?)" is an admin user$/ do |user_name|
  within("li.#{user_name}") do
    find("input##{user_name}").should be_checked
  end
end

Then /^I should see that users "(.*?)" are not admin users$/ do |user_names|
  user_names.split(",").each do |user_name|
    within("li.#{user_name}") do
      find("input##{user_name}").should_not be_checked
    end
  end
end

