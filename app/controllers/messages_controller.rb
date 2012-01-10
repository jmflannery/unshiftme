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
    @new_messages = Message.new_messages_for(current_user)
    @new_messages.each do |message|
      message.mark_sent_to(current_user)
      print current_user.full_name + "\n"
    end
  end
end
