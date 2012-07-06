namespace :cron do
 desc "Sign out all users with no heartbeat"
  task sign_out_the_dead: :environment do
    User.sign_out_the_dead
  end
end
