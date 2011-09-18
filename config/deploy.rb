set :application, "intercom"
set :repository,  "https://jmflannery@github.com/jmflannery/intercom.git"

set :scm, :git

set :deploy_to, "/var/www/intercom"

set :branch, "master"

set :deploy_via, :remote_cache

role :web, "amtrak-intercom.amtrak.ad.nrpc"   # Your HTTP server, Apache/etc
role :app, "amtrak-intercom.amtrak.ad.nrpc"   # This may be the same as your `Web` server
role :db,  "amtrak-intercom.amtrak.ad.nrpc", :primary => true # This is where Rails migrations will run
#role :db,  "your slave db-server here"

# if you're still using the script/reaper helper you will need
# these http://github.com/rails/irs_process_scripts

# Passenger
namespace :deploy do
  desc "Restarting mod_rails with restart.txt"
  task :restart, :roles => :app, :except => { :no_release => true } do
    run "touch #{current_path}/tmp/restart.txt"
  end

  [:start, :stop].each do |t|
    desc "#{t} task is a no-op with mod_rails"
    task t, :roles => :app do ; end
  end
end

