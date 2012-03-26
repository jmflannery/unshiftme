class MessagesController < ApplicationController
  before_filter :authenticate
  
  def create
    @user = current_user
    @message = @user.messages.build(params[:message])

    if @message.save
      @message.set_recievers
      @recipient_names = ["/messages/#{@user.name}"]
      #PrivatePub.publish_to "/messages/#{@user.name}", chat_message: @message.content
    
      @user.recipients.each do |recipient|
        if User.exists?(recipient.recipient_user_id)
          recip_user = User.find(recipient.recipient_user_id) 
          @recipient_names << "/messages/#{recip_user.name}"
          #PrivatePub.publish_to "/messages/#{recip_user.name}", chat_message: @message.content 
          recip_user.add_recipient(@user.id) 
        end
      end
    else
      render 'sessions/new'
    end
  end
end
