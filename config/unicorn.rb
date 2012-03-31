root = "/home/deployer/apps/amtrak_messenger/current"
working_directory root

pid "#{root}/tmp/pids/unicorn.pid"
stderr_path "#{root}/log/unicorn.log"
stdout_path "#{root}/log/unicorn.log"

listen "/tmp/unicorn.amtrak_messenger.sock"
worker_processes 2
timeout 30
