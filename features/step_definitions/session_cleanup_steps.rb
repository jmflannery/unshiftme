When /^I close the browser without signing out$/ do
  page.execute_script "window.close();"
end

Given /^My last heartbeat was (\d+) seconds ago$/ do |sec|
   @user.lastpoll.should be_nil
end

