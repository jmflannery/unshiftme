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
    start_time = Time.parse(params[:start_time]) if params.has_key?(:start_time)
    end_time = Time.parse(params[:end_time]) if params.has_key?(:end_time)
    logger.debug "start time: #{start_time}"
    logger.debug "end time: #{end_time}"
    if !start_time and !end_time
      messages = Message.for_user_before(current_user, Time.now)
    elsif start_time and !end_time
      messages = Message.for_user_before(current_user, start_time)
    elsif start_time and end_time
      user_id = params[:user_id] if params.has_key?(:user_id)
      trans_user = User.find_by_id(user_id)
      if trans_user
        messages = Message.for_user_between(trans_user, start_time, end_time)
      end
    end
    if messages
      messages.each { |message| message.set_view_class(current_user) }
      respond_to do |format|
        format.json {
          render json: messages.as_json
        }
      end
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

