class Attachment < ActiveRecord::Base
  belongs_to :user
  belongs_to :message
  has_many :incoming_receipts
  has_many :receivers, :through => :incoming_receipts, :source => :workstation
  has_one :outgoing_receipt
  has_one :sender, through: :outgoing_receipt, source: :user

  mount_uploader :payload, AttachmentUploader

  def self.for_user(user)
    attachments = []
    attachments.concat(Attachment.joins(:incoming_receipts).where(
      "incoming_receipts.user_id = ? or incoming_receipts.workstation_id in (?)",
      user.id, user.workstation_ids))
    attachments.concat(Attachment.joins(:outgoing_receipt).where("outgoing_receipts.user_id = ?", user.id))
    attachments
  end
end
