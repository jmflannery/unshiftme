class MessagesController < ApplicationController
  before_filter :authenticate
  
  def create
    @user = current_user
    @message = @user.messages.build(params[:message])
    if @message.save
      @message.view_class = "message #{@message.id} owner"
      @message.set_recievers
      @user.recipients.each do |recipient|
        if User.exists?(recipient.recipient_user_id)
          recip_user = User.find(recipient.recipient_user_id) 
          recip_user.add_recipient(@user.id)
          data = { sender: @user.name, 
                   chat_message: @message.content,
                   timestamp: @message.created_at.strftime("%a %b %e %Y %T"),
                   view_class: "message #{@message.id.to_s} recieved unread" }
          PrivatePub.publish_to("/messages/#{recip_user.name}", data)
        end
      end
    else
      render 'sessions/new'
    end
  end
  
  def update
    if Message.exists?(params[:id])
      @message = Message.find(params[:id])
      @message.mark_read_by(current_user)
    end 
  end
end
