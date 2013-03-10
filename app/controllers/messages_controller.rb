class MessagesController < ApplicationController
  before_filter :authenticate
  
  def create
    @user = current_user
    @message = @user.messages.new(params[:message])
    if @message.save
      @message.generate_incoming_receipts
      @message.generate_outgoing_receipt
      @message.broadcast
    end
  end

  def index
    options = {}
    start_time = params.fetch(:start_time){""} 
    end_time = params.fetch(:end_time){""}
    options[:start_time] = Time.parse(start_time) unless start_time.blank?
    options[:end_time] = Time.parse(end_time) unless end_time.blank?
    messages = current_user.display_messages(options)
    respond_to do |format|
      format.json {
        render json: messages.map { |msg| MessagePresenter.new(msg, current_user).as_json }
      }
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

