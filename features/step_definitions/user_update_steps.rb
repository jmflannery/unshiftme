When /^I enter "(.*?)" for "(.*?)"$/ do |user_name, field|
  fill_in field, :with => user_name
end

