FactoryGirl.define do
  factory :desk, class: Desk do |desk|
    sequence(:name) { |n| "CUS North #{n}" }
    sequence(:abrev) { |n| "CUS#{n}" }
    job_type "td"
    sequence(:user_id) { |n| n }
  end
end
