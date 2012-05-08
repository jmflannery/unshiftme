class Attachment < ActiveRecord::Base
  belongs_to :user

  serialize :recievers

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
    recievers_list = []
    user.recipients.each do |recipient|
      desk = Desk.find_by_id(recipient.desk_id)
      recip_user = User.find_by_id(desk.user_id)
      node = { desk_id: desk.id }
      node = node.merge({ user_id: recip_user.id }) if recip_user
      recievers_list << node
    end
    self.recievers = recievers_list
    save
  end 
end
