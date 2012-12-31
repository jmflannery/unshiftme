FactoryGirl.define do
  factory :transcript, class: Transcript do |transcript|
    association :user, factory: :user
    association :transcript_user, factory: :user
    association :transcript_workstation, factory: :workstation
    transcript.start_time 5.hours.ago
    transcript.end_time 1.minute.ago
  end
end
