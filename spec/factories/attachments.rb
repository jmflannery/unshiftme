# == Schema Information
#
# Table name: attachments
#
#  id           :integer         not null, primary key
#  user_id      :integer
#  file         :binary
#  created_at   :datetime        not null
#  updated_at   :datetime        not null
#  name         :string(255)
#  content_type :string(255)
#

# Read about factories at http://github.com/thoughtbot/factory_girl

#FactoryGirl.define do
#  factory :attachment do
#    user_id 1
#    recipient_id 1
#    file ""
#  end
#end
