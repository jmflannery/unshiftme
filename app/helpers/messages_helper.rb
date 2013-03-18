module MessagesHelper

  def publish_to_many(channels, data = nil, &block)
    channels.each do |channel|
      PrivatePub.publish_to(channel, data || capture(&block))
    end
  end 

  def broadcast(message)
    sent_to = []
    message.user.recipients.each do |recipient|
      if recipient.user
        unless sent_to.include?(recipient.user.id)
          sent_to << recipient.user.id

          PrivatePub.publish_to("/messages/#{recipient.user.user_name}",
                                MessagePresenter.new(message, recipient.user).as_json)
        end
      end
    end
  end
end
