FactoryGirl.define do
  factory :user, class: User do |user|
    sequence(:user_name) { |n| "person#{n}" }
    password "secret"
    password_confirmation "secret"
    admin false
    status false
  end
end
