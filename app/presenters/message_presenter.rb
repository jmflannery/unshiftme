class MessagePresenter

  attr_reader :message, :user

  def initialize(message, user)
    @message = message
    @user = user
  end

  def as_json
    hash = {}
    hash[:id] = message.id
    hash[:content] = message.content
    hash[:created_at] = message.created_at.strftime("%a %b %e %Y %T")
    hash[:sender] = message.sender_handle
    hash[:attachment_url] = message.attachment.payload.url if message.attachment
    hash[:view_class] = message.generate_view_class(user)
    hash[:readers] = message.formatted_readers unless message.sent_to?(user)
    hash.as_json
  end
end

