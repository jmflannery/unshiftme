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
          data = { message_id: @message.id, sender: @user.name, chat_message: @message.content, timestamp: @message.created_at.strftime("%a %b %e %Y %T") }
          PrivatePub.publish_to("/messages/#{recip_user.name}", data)
        end
      end
    else
      render 'sessions/new'
    end
  end
  
  def update
    @message_id = params[:message_id]
    if Message.exists?(@message_id)
      @message = Message.find(@message_id)
      @message.mark_read_by(current_user)
    end 
  end
end
