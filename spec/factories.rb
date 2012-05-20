FactoryGirl.define do

  factory :user, class: User do |user|
    sequence(:user_name) { |n| "person#{n}" }
    password "secret"
    password_confirmation "secret"
    admin false
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
  factory :attachment, class: Attachment do |attachment|
    attachment.payload Rails.root + "spec/fixtures/files/test_file.txt"
    association :user, factory: :user
  end
end
