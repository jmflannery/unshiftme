Factory.define :user do |user|
  user.name "CHM"
  user.full_name "Chesty H. McGee"
  user.email "chesty@sluts.com"
  user.password "dirtysanchez"
  user.password_confirmation "dirtysanchez"
  user.status false
end

Factory.sequence :email do |n|
  "person-#{n}@example.com"
end

Factory.define :message do |message|
  message.content "Foo bar"
  message.association :user
end

Factory.define :recipient do |recipient|
  recipient.recipient_user_id 22
  recipient.association :user
end

Factory.define :attachment do |attachment|
  attachment.file Rails.root + "spec/fixtures/files/test_file.txt"
  attachment.association :user
end
