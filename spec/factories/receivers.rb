FactoryGirl.define do
  factory :receiver, class: Receiver do |receiver|
    association :workstation, factory: :workstation
    association :user, factory: :user
  end
end
