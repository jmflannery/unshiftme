class MessagesController < ApplicationController
  before_filter :authenticate
  
  def create
    @user = current_user
    @message = @user.messages.new(params[:message])
    if @message.save
      @message.view_class = "message #{@message.id} owner"
      @message.broadcast
      @message.set_receivers
      @message.generate_outgoing_receipt
    end
  end
  
  def index
    user = User.find_by_id(params[:user_id]) if params.has_key?(:user_id)
    user = current_user if user.nil?
    workstation = Workstation.find_by_id(params[:workstation_id]) if params.has_key?(:workstation_id)
    st = params[:start_time] if params.has_key?(:start_time)
    et = params[:end_time] if params.has_key?(:end_time)
    start_time = Time.parse(st) unless st.blank?
    end_time = Time.parse(et) unless et.blank?
    if !start_time and !end_time
      messages = Message.for_user_before(user, Time.now)
    elsif start_time and !end_time
      messages = Message.for_user_before(user, start_time)
    elsif start_time and end_time
      messages = Message.for_user_between(user, start_time, end_time)
    end
    if messages
      messages.each { |message| message.set_view_class(user) }
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
        readers: @message.formatted_readers,
        message: @message.id
      }  
      message_owner = User.find(@message.user_id)
      PrivatePub.publish_to("/readers/#{message_owner.user_name}", data)
    end 
  end
end

