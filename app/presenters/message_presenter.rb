class MessagePresenter

  attr_reader :messages, :user

  def initialize(messages, user)
    @messages = messages
    @user = user
  end

  def as_json(options = {})
    if messages.respond_to?(:map)
      array_as_json(options)
    else
      message_as_json(options)
    end
  end

  def array_as_json(options = {})
    messages.map do |message|
      single_message_as_json(message, options)
    end
  end

  def message_as_json(options = {})
    single_message_as_json(messages, options)
  end

  private

  def single_message_as_json(message, options = {})
    hash = {}
    hash[:id] = message.id
    hash[:content] = message.content
    hash[:created_at] = message.created_at.strftime("%a %b %e %Y %T")
    hash[:sender] = message.sender_handle
    hash[:attachment_url] = message.attachment.payload_url if message.attachment
    hash[:view_class] = message.generate_view_class(user)
    hash[:readers] = message.formatted_readers unless message.sent_to?(user) and not options[:transcript]
    hash
  end
end
