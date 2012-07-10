When /^I close the browser without signing out$/ do
  page.execute_script "window.close();"
  User.sign_out_the_dead
end

Given /^My last heartbeat was (\d+) seconds ago$/ do |sec|
   @user.set_heartbeat(sec.to_i.seconds.ago)
end

Then /^I should have no recipients$/ do
  @user.recipients.should be_empty
end

