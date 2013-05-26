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
end

