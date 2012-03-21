class MessagesController < ApplicationController
  before_filter :authenticate
  
  def create
    @user = current_user
    @recipient_names = ["/messages/#{@user.name}"]
    @user.recipients.each do |recipient|
      if User.exists?(recipient.recipient_user_id)
        recip_user = User.find(recipient.recipient_user_id) 
        @recipient_names << "/messages/#{recip_user.name}"
      end
    end

    @message = @user.messages.build(params[:message])

    if @message.save
      @message.set_recievers
    else
      render 'sessions/new'
    end
  end
end
