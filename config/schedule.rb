set :output, "#{path}/log/cron.log"

every 1.day, at: '4:20 am' do
  command "[ -f /home/deployer/dumps/gtm_production_previous.dmp ] && mv /home/deployer/dumps/gtm_production_previous.dmp /home/deployer/dumps/gtm_production_remove"
end

every 1.day, at: '4:21 am' do
  command "[ -f /home/deployer/dumps/gtm_production.dmp ] && mv /home/deployer/dumps/gtm_production.dmp /home/deployer/dumps/gtm_production_previous.dmp"
end

every 1.day, at: '4:22 am' do
  command "pg_dump gtm_production > /home/deployer/dumps/gtm_production.dmp"
end

every 1.day, at: '4:25 am' do
  command "[ -f /home/deployer/dumps/gtm_production_remove ] && rm /home/deployer/dumps/gtm_production_remove"
end
