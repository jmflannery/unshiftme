FactoryGirl.define do
  factory :recipient, class: Recipient do |recipient|
    association :user, factory: :user
    association :workstation, factory: :workstation
  end
end

