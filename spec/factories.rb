FactoryGirl.define do

  factory :user, class: User do |user|
    first_name "Chesty"
    middle_initial "H"
    last_name "McGee"
    user_name "chmcgee"
    email "chesty@sluts.com"
    password "dirtysanchez"
    password_confirmation "dirtysanchez"
    status false
  end

  factory :user1, class: User do
    first_name "Wally"
    middle_initial "W"
    last_name "Wallerson"
    user_name "wwwwallerson"
    email "wally@thewall.com"
    password "dirtysanchez"
    password_confirmation "dirtysanchez"
    status false
  end

  factory :user2, class: User do
    first_name "Sally"
    middle_initial "T"
    last_name "Fields"
    user_name "stfields"
    email "sally@sallyfields.com"
    password "ilikecake"
    password_confirmation "ilikecake"
    status false
  end

  factory :user3, class: User do
    first_name "Jimmy"
    middle_initial "G"
    last_name "Johnson"
    user_name "jgjohnson"
    email "jimmy@jj.com"
    password "nascar"
    password_confirmation "nascar"
    status false
  end
end

#Factory.sequence :email do |n|
#  "person-#{n}@example.com"
#end

FactoryGirl.define do
  
  factory :message, class: Message do |message|
    message.content "this is just a message"
    association :user, factory: :user
  end

  factory :message1, class: Message do |message|
    message.content "Foo bar"
    association :user, factory: :user1
  end

  factory :message2, class: Message do |message|
    message.content "What the? Who the?"
    association :user, factory: :user2
  end

  factory :message3, class: Message do |message|
    message.content "I have nothing to say"
    association :user, factory: :user3
  end
end

FactoryGirl.define do

  factory :recipient, class: Recipient do |recipient|
    recipient.recipient_user_id 22
    association :user, factory: :user
  end

  factory :recipient1, class: Recipient do |recipient|
    recipient.recipient_user_id 22
    association :user, factory: :user1
  end

  factory :recipient2, class: Recipient do |recipient|
    recipient.recipient_user_id 22
    association :user, factory: :user2
  end

  factory :recipient3, class: Recipient do |recipient|
    recipient.recipient_user_id 22
    association :user, factory: :user3
  end
end

FactoryGirl.define do
  factory :attachment, class: Attachment do |attachment|
    attachment.payload Rails.root + "spec/fixtures/files/test_file.txt"
    association :user, factory: :user
  end
end
