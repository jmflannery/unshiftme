Given /^I am in (.*) browser$/ do |name|
  Capybara.session_name = name
end
 
Given /^I am logged in as "([^\"]*)" with password "([^\"]*)" at "([^\"]*)"$/ do |username, password, workstations|
  unless username.blank?
    visit signin_path
    fill_in "User name", :with => username
    fill_in "Password", :with => password
    workstations.split(",").each { |workstation| check workstation }
    click_button "Sign In"
  end
end

#Given /^I am registered user "(.*?)" logged in with password "(.*?)"$/ do |user, password|
#  if user.include?('@')
#    user_name, workstation = parse_handle(user)
#    FactoryGirl.create(:user, user_name: user_name, password: password)
#    visit signin_path
#    fill_in "User name", :with => user_name
#    fill_in "Password", :with => password
#    check workstation.abrev
#    click_button "Sign In"
#  else
#    FactoryGirl.create(:user, user_name: user, password: password)
#    visit signin_path
#    fill_in "User name", :with => user
#    fill_in "Password", :with => password
#    click_button "Sign In"
#  end
#end

def parse_handle(user_handle)
  handle = user_handle.slplit('@')
  if handle.size == 2
    user_name = handle[0]
    workstation_name = handle[1]
    workstation = Workstation.where(name: workstation_name) if workstation_name
    [user_name, workstation]
  else
    ["", ""]
  end
end

Given /^the following (.+) records?$/ do |factory, table|
  records = []
  table.hashes.each do |hash|
    records << FactoryGirl.create(factory, hash)
  end
  @test_records ||= Hash.new()
  @test_records[factory.to_sym] = records unless @test_records.has_key?(factory.to_sym)
end

When /^I press the "(.*?)" key$/ do |key|
  page.execute_script("$('form#new_message').submit()")
end

When /^I tab away$/ do
  page.execute_script("$('body').focus()")
end

When /^I fill in "(.*?)" with "(.*?)"$/ do |arg1, arg2|
  fill_in arg1, with: arg2
end

When /^I press "(.*?)"$/ do |arg1|
  click_button arg1
end

When /^I click link "(.*?)"$/ do |arg1|
  click_link arg1 
end

When /^I select "(.*?)" for "(.*?)"$/ do |item, field|
  select(item, from: field)
end

When /^I wait (\d+) seconds?$/ do |seconds|
  sleep seconds.to_i
end

When /^I select date "(.*?)" for "(.*?)"$/ do |time_str, field|
  time = DateTime.parse(time_str)
  select(time.strftime("%Y"), from: "#{field}_1i")
  select(time.strftime("%B"), from: "#{field}_2i")
  select(time.strftime("%d"), from: "#{field}_3i")
  select(time.strftime("%H"), from: "#{field}_4i")
  select(time.strftime("%M"), from: "#{field}_5i")
end

Then /^I should see "(.*?)"$/ do |text|
  page.should have_content(text)
end

