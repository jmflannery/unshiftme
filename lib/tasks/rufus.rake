namespace :rufus do
  desc "Start the rufus background worker to cleanup inactive users"
  task scheduler: :environment do
    require "#{Rails.root}/config/rufus.rb"
    
    $rufus_scheduler.join
  end

  desc "Stop rufus"
  task stop: :environment do
  end
end
