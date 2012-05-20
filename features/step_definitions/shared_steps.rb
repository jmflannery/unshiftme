Given /^I am in (.*) browser$/ do |name|
  Capybara.session_name = name
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
  find_field('message_content').native.send_key(key.to_sym)
end

When /^I fill in "(.*?)" with "(.*?)"$/ do |arg1, arg2|
  fill_in arg1, with: arg2
end

When /^I press "(.*?)"$/ do |arg1|
  click_button arg1
end

When /^I wait (\d+) seconds?$/ do |seconds|
  sleep seconds.to_i
end
