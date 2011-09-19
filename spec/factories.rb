Factory.define :user do |user|
  user.name "CHM"
  user.full_name "Chesty H. McGee"
  user.email "chesty@sluts.com"
  user.password "dirtysanchez"
  user.password_confirmation "dirtysanchez"
end

Factory.sequence :email do |n|
  "person-#{n}@example.com"
end

Factory.define :message do |message|
  message.content "Foo bar"
  message.association :user
end

