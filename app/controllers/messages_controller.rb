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
    @new_messages = Message.since(Time.at(params[:after].to_i + 1))
  end
end
