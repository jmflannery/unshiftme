class Attachment < ActiveRecord::Base
  belongs_to :user

  mount_uploader :payload, AttachmentUploader

  serialize :recievers

  def set_recievers
    recievers_list = []
    user.recipients.each do |recipient|
      workstation = Workstation.find_by_id(recipient.workstation_id)
      recip_user = User.find_by_id(workstation.user_id)
      node = { workstation_id: workstation.id }
      node = node.merge({ user_id: recip_user.id }) if recip_user
      recievers_list << node
    end
    self.recievers = recievers_list
    save
  end 
end

