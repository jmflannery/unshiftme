module MessagesHelper
  def publish_to_many(channels, data = nil, &block)
    channels.each do |channel|
      PrivatePub.publish_to(channel, data || capture(&block))
    end
  end 
end
