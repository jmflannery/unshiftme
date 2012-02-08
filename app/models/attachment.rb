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

class Attachment < ActiveRecord::Base
  belongs_to :user

  has_attached_file :payload,
    storage: :s3, 
    s3_credentials: "#{Rails.root}/config/s3.yml",
    bucket: "jacks",
    path: "chatty_pants/attachments/"

  def set_recievers
    recipients = self.user.recipients
    count = 0
    recipient_user_ids = ""
    recipients.each do |recipient|
      recipient_user_ids << "," unless count == 0
      recipient_user_ids << recipient.recipient_user_id.to_s
      count += 1
    end
    self.recievers = recipient_user_ids
    self.save
  end 
end
