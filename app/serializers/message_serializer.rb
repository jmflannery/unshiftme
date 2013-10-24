class MessageSerializer < ActiveModel::Serializer
  attributes :id, :content, :created_at, :sender, :attachment_url, :view_class, :readers

  def created_at
    object.created_at.strftime("%a %b %e %Y %T")
  end

  def sender
    object.sender_handle
  end

  def attachment_url
    object.attachment.payload_url if object.attachment
  end

  def view_class
    object.generate_view_class(current_user)
  end

  def readers
    object.formatted_readers unless object.sent_to?(current_user)
  end
end
