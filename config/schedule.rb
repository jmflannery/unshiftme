set :output, "#{path}/log/cron.log"

every 1.minute do
  rake "cron:sign_out_the_dead"
end
