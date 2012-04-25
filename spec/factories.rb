FactoryGirl.define do

  factory :user, class: User do |user|
    first_name "Example"
    middle_initial "X"
    last_name "Person"
    sequence(:user_name) { |n| "experson#{n}" }
    sequence(:email) { |n| "eperson#{n}@example.com" }
    password "dirtysanchez"
    password_confirmation "dirtysanchez"
    status false
  end
end

FactoryGirl.define do
  
  factory :message, class: Message do |message|
    message.content "this is just a message"
    association :user, factory: :user
  end
end

FactoryGirl.define do

  factory :recipient, class: Recipient do |recipient|
    recipient.recipient_user_id 22
    association :user, factory: :user
  end
end

FactoryGirl.define do
  factory :attachment, class: Attachment do |attachment|
    attachment.payload Rails.root + "spec/fixtures/files/test_file.txt"
    association :user, factory: :user
  end
end

FactoryGirl.define do
  factory :transcript, class: Transcript do |transcript|
    transcript.watch_user_id 22
    transcript.start_time "2012-04-24 17:52:39"
    transcript.end_time "2012-04-24 18:52:39"
    association :user, factory: :user
  end
end
