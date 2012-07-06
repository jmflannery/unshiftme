require 'rubygems'
require 'rufus/scheduler'

$scheduler = Rufus::Scheduler.start_new

$scheduler.every '20s' do
  User.sign_out_the_dead
end
