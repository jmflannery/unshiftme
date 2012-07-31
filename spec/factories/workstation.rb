FactoryGirl.define do
  factory :workstation, class: Workstation do |workstation|
    sequence(:name) { |n| "CUS North #{n}" }
    sequence(:abrev) { |n| "CUS#{n}" }
    job_type "td"
    sequence(:user_id) { |n| n }
  end
end
