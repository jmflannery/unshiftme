FactoryGirl.define do
  factory :outgoing_receipt, class: OutgoingReceipt do |outgoing_receipt|
    association :message, factory: :message
    association :user, factory: :user
  end
end
