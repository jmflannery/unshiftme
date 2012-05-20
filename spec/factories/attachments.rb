FactoryGirl.define do
  factory :attachment, class: Attachment do |attachment|
    attachment.payload Rails.root + "spec/fixtures/files/test_file.txt"
    association :user, factory: :user
  end
end
