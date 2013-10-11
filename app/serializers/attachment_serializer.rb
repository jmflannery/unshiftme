class AttachmentSerializer < ActiveModel::Serializer
  attributes :id, :payload_identifier, :payload_url
end
