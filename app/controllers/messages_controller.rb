class MessagesController < ApplicationController
  before_filter :authenticate
  
  def create
    @message = current_user.messages.build(params[:message])
    if @message.save
      @message.set_recievers
    else
      render 'sessions/new'
    end
  end
  
  def index
    user = nil
    respond_to do |format|
      format.html {user = current_user}
      format.js {user = User.find(params[:user_id])}
    end
    
    user.timestamp_poll(Time.now)
    user.remove_stale_recipients

    @my_recipients = Recipient.my_recipients(user.id)

    @new_messages = Message.new_messages_for(user)
    @new_messages.each do |message|
      message.mark_sent_to(user)
    end
  end
end
