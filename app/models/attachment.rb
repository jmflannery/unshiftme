class Attachment < ActiveRecord::Base
  belongs_to :user

  mount_uploader :payload, AttachmentUploader

  serialize :recievers

  def set_recievers
    recievers_list = []
    user.recipients.each do |recipient|
      node = { workstation_id: recipient.id }
      node = node.merge({ user_id: recipient.user.id }) if recipient.user
      recievers_list << node
    end
    self.recievers = recievers_list
    save
  end 
end

