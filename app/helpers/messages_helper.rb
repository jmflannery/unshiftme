module MessagesHelper
  def publish_to_many(channels, data = nil, &block)
    puts "publish to many #{channels.join(", ")}"
    channels.each do |channel|
      puts "publishing to #{channel}" 
      PrivatePub.publish_to(channel, data || capture(&block))
    end
  end 
end
