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

  has_attached_file :payload

  #def uploaded_file=(upload_file)
  #  self.name = base_part_of(upload_file.original_filename)
  #  self.content_type = upload_file.content_type.chomp
  #  self.file = upload_file.read
  #end

  #def base_part_of(file_name)
  #  File.basename(file_name).gsub(/[^\w._-]/, '')
  #end

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