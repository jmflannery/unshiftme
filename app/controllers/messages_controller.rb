class MessagesController < ApplicationController
  before_filter :authenticate
  
  def create
    @user = current_user
    @message = @user.messages.build(params[:message])
    if @message.save
      @message.view_class = "message #{@message.id} owner"
      @message.broadcast
      @message.set_sent_by
    else
      redirect_to new_session_path
    end
  end
  
  def update
    if Message.exists?(params[:id])
      @message = Message.find(params[:id])
      @message.mark_read_by(current_user)

      data = {
        readers: @message.readers,
        message: @message.id
      }  
      message_owner = User.find(@message.user_id)
      PrivatePub.publish_to("/readers/#{message_owner.user_name}", data)
    end 
  end
end

