FactoryGirl.define do
  factory :message, class: Message do |message|
    message.content "this is just a message"
    association :user, factory: :user
  end
end
