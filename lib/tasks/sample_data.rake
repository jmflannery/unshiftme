namespace :db do
  desc "Fill database with sample data"
  task :populate => :environment do
    50.times do
      User.all(:limit => 6).each do |user|
        user.messages.create!(:content => Faker::Lorem.sentance(5))
      end
    end
  end
end
