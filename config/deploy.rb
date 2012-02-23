set :application, "chatty_pants"
set :repository,  "https://jmflannery@github.com/jmflannery/chatty_pants.git"

set :scm, :git

set :deploy_to, "/var/www"

set :branch, "master"

set :deploy_via, :remote_cache

set :user, "deploy"

set :port, 30000

set :deploy_via, :copy

set :copy_stategy, :export

set :use_sudo, false

set :rake, "/home/deploy/.rvm/gems/ruby-1.9.3-p125/bin/rake"

role :web, "50.56.191.206"   # Your HTTP server, Apache/etc
role :app, "50.56.191.206"   # This may be the same as your `Web` server
role :db,  "50.56.191.206", :primary => true # This is where Rails migrations will run
#role :db,  "your slave db-server here"

# if you're still using the script/reaper helper you will need
# these http://github.com/rails/irs_process_scripts

# Passenger
#namespace :deploy do
#  desc "Restarting mod_rails with restart.txt"
#  task :restart, :roles => :app, :except => { :no_release => true } do
#    run "touch #{current_path}/tmp/restart.txt"
#  end
#
#  [:start, :stop].each do |t|
#    desc "#{t} task is a no-op with mod_rails"
#    task t, :roles => :app do ; end
#  end
#end

