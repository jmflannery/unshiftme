namespace :cron do
 desc "Sign out all users with no heartbeat"
  task sign_out_the_dead: :environment do
    puts "$$ Begin $$"
    User.sign_out_the_dead
    puts "%% end %%"
  end
end
