root = "/home/deployer/apps/chatty_pants/current"
working_directory root

pid "#{root}/tmp/pids/unicorn.pid"
stderr_path "#{root}/log/unicorn.log"
stdout_path "#{root}/log/unicorn.log"

listen "/tmp/unicorn.chatty_pants.sock"
worker_processes 2
timeout 30
