# == Schema Information
#
# Table name: attachments
#
#  id                   :integer         not null, primary key
#  user_id              :integer
#  created_at           :datetime        not null
#  updated_at           :datetime        not null
#  recievers            :string(255)
#  delivered            :string(255)
#  payload_file_name    :string(255)
#  payload_content_type :string(255)
#  payload_file_size    :integer
#  payload_updated_at   :datetime
#

# Read about factories at http://github.com/thoughtbot/factory_girl

#FactoryGirl.define do
#  factory :attachment do
#    user_id 1
#    recipient_id 1
#    file ""
#  end
#end
