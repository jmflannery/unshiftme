Then /^my heartbeat should be less than or equal to the current time$/ do
  @user.reload
  @user.lastpoll.should <= Time.now
end

Then /^I should be signed in$/ do
  @user.reload
  @user.status.should be_true
end
