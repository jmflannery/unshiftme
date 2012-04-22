require "bundler/capistrano"

server "50.56.191.206", :web, :app, :db, primary: true

set :application, "amtrak_messenger"
set :user, "deployer"
set :deploy_to, "/home/#{user}/apps/#{application}"
set :deploy_via, :remote_cache
set :use_sudo, false

set :scm, :git
set :repository, "git@github.com:jmflannery/#{application}.git"
set :branch, "master"

set :faye_pid, "#{deploy_to}/shared/pids/faye.pid"
set :faye_config, "#{deploy_to}/current/private_pub.ru"

default_run_options[:pty] = true
ssh_options[:forward_agent] = true

after "deploy", "deploy:cleanup" # keep only the last 5 releases

namespace :deploy do
  %w[start stop restart].each do |command|
    desc "#{command} unicorn server"
    task command, roles: :app, except: {no_release: true} do
      run "/etc/init.d/unicorn_#{application} #{command}"
    end
  end

  task :setup_config, roles: :app do
    sudo "ln -nfs #{current_path}/config/nginx.conf /etc/nginx/sites-enabled/#{application}"
    sudo "ln -nfs #{current_path}/config/unicorn_init.sh /etc/init.d/unicorn_#{application}"
    run "mkdir -p #{shared_path}/config"
    put File.read("config/database.example.yml"), "#{shared_path}/config/database.yml"
    puts "Now edit the config files in #{shared_path}."
  end
  after "deploy:setup", "deploy:setup_config"

  task :symlink_config, roles: :app do
    run "ln -nfs #{shared_path}/config/database.yml #{release_path}/config/database.yml"
  end
  after "deploy:finalize_update", "deploy:symlink_config"

  desc "Make sure local git is in sync with remote."
  task :check_revision, roles: :web do
    unless `git rev-parse HEAD` == `git rev-parse origin/master`
      puts "WARNING: HEAD is not the same as origin/master"
      puts "Run `git push` to sync changes."
      exit
    end
  end
  before "deploy", "deploy:check_revision"

  #desc "Start Faye server."
  #task :start_push_server, roles: :web do
  #  run "cd #{current_path} && nohup bundle exec rackup private_pub.ru -s thin -E production"
  #end
  #after "deploy:symlink_config", "deploy:start_push_server"
end

namespace :faye do
  desc "Start Faye"
  task :start do
    run "cd #{deploy_to}/current && bundle exec rackup #{faye_config} -s thin -E production -D"
  end
  desc "Stop Faye"
  task :stop do
    run "kill `cat #{faye_pid}` || true"
  end
end

namespace :db do
  desc "Reset production database"
  task :reset do
    run("cd #{deploy_to}/current && /usr/bin/env rake db:reset RAILS_ENV=production")
  end
end
#before 'deploy:update_code', 'faye:stop'
#after 'deploy:finalize_update', 'faye:start'
