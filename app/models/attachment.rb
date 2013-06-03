class Attachment < ActiveRecord::Base
  belongs_to :user
  belongs_to :message
  has_many :incoming_receipts
  has_many :receivers, :through => :incoming_receipts, :source => :workstation

  mount_uploader :payload, AttachmentUploader

  def as_json
    {
      payload_identifier: payload_identifier,
      payload_url: payload_url,
      id: id
    }
  end

  def self.for_user(user)
    attachments = Attachment.joins(:incoming_receipts).where(
      "incoming_receipts.user_id = ? or incoming_receipts.workstation_id in (?)",
      user.id, user.workstation_ids)
    ogs = OutgoingReceipt.where("user_id = ?", user.id)
    ogs.select! { |r| r.message.attachment }
    attachments.concat(ogs.map { |r| r.message.attachment })
    attachments
  end
end
