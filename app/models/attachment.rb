class Attachment < ActiveRecord::Base
  belongs_to :user

  has_attached_file :payload

  def uploaded_file=(upload_file)
    self.name base_part_of(upload_file.original_filename)
    self.content_type = upload_file.content_type.chomp
    self.file = upload_file.read
  end

  def base_part_of(file_name)
    File.basename(file_name).gsub(/[^\w._-]/, '')
  end

  def set_recievers
    first = true
    recipient_user_ids = ""
    user.recipients.each do |recipient|
      recipient_user_ids << "," unless first
      recipient_user_ids << recipient.recipient_user_id.to_s
      first = false
    end
    self.recievers = recipient_user_ids
    save
  end 
end
