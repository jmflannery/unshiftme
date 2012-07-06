namespace :rufus do
  desc "Start the rufus worker"
  task scheduler: :environment do
    require "#{Rails.root}/config/rufus.rb"

    $scheduler.join  
  end
end
