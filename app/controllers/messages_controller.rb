class MessagesController < ApplicationController
  before_filter :authenticate
  
  def create
    @user = current_user
    @message = @user.messages.new(params[:message])
    if @message.save
      @message.view_class = "message #{@message.id} owner"
      @message.broadcast
      @message.set_receivers
      @message.set_sender_workstations
    end
  end
  
  def index
    time = params.has_key?(:time) ? params[:time] : Time.now
    messages = Message.for_user_before(current_user, time)
    respond_to do |format|
      format.json {
        render json: messages.as_json
      }
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

