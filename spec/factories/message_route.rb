FactoryGirl.define do
  factory :message_route, class: MessageRoute do |recipient|
    association :user, factory: :user
    association :workstation, factory: :workstation
  end
end

