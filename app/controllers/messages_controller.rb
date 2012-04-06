class MessagesController < ApplicationController
  before_filter :authenticate
  
  def create
    @user = current_user
    @message = @user.messages.build(params[:message])
    if @message.save
      @message.view_class = "my_message"
      @message.set_recievers
      @user.recipients.each do |recipient|
        if User.exists?(recipient.recipient_user_id)
          recip_user = User.find(recipient.recipient_user_id) 
          recip_user.add_recipient(@user.id) 
          data = { sender: @user.name, chat_message: @message.content, timestamp: @message.created_at.strftime("%H:%M:%S") }
          PrivatePub.publish_to("/messages/#{recip_user.name}", data)
        end
      end
    else
      render 'sessions/new'
    end
  end
end
