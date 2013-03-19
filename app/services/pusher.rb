class Pusher

  class << self

    def push_message(message)
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
end
