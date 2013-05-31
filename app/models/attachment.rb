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
    irs = IncomingReceipt.where("user_id = ? and attachment_id is not null", user.id)
    attachments = irs.map { |r| r.attachment }
    ogs = OutgoingReceipt.where("user_id = ?", user.id)
    ogs.select! { |r| r.message.attachment }
    attachments.concat(ogs.map { |r| r.message.attachment })
    attachments
  end
end

