Then /^I should see the Transcript page$/ do
  page.should have_content("Transcripts")
end

Then /^I should see a New Transcripts button$/ do
  page.should have_selector("a", content: "New Transcript")
end

Then /^I should see that I have (\d+) Transcripts$/ do |count|
  page.should have_content("#{count} transcripts.")
  count = count.to_i
  if count == 0
    page.should_not have_selector("#transcripts ul li")
  elsif count > 0
    page.should have_selector("#transcripts ul li", count: count)
  end
end

