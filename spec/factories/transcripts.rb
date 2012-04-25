FactoryGirl.define do
  factory :transcript, class: Transcript do |transcript|
    transcript.watch_user_id 22
    transcript.start_time "2012-04-24 17:52:39"
    transcript.end_time "2012-04-24 18:52:39"
    association :user, factory: :user
  end
end
