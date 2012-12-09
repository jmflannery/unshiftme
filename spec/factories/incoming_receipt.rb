FactoryGirl.define do
  factory :incoming_receipt, class: IncomingReceipt do |incoming_receipt|
    association :message, factory: :message
    association :workstation, factory: :workstation
    association :user, factory: :user
  end
end
