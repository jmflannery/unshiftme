require 'rubygems'
require 'rufus/scheduler'

$rufus_scheduler = Rufus::Scheduler.start_new

$rufus_scheduler.every '20s' do
  User.sign_out_the_dead
end
