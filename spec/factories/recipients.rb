FactoryGirl.define do
  factory :recipient, class: Recipient do |recipient|
    recipient.desk_id 22
    association :user, factory: :user
  end
end
