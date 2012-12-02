FactoryGirl.define do
  factory :user, class: User do |user|
    sequence(:user_name) { |n| "person#{n}" }
    password "secret"
    password_confirmation "secret"
    normal_workstations []
    admin false
  end
end

