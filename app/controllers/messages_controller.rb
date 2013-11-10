class MessagesController < ApplicationController
  before_filter :authenticate
  
  def create
    @user = current_user
    @message = @user.messages.new(message_params)
    if @message.save
      @message.generate_incoming_receipts
      @message.generate_outgoing_receipt
      Pusher.push_message(@message)
    end
  end

  def index
    render json: current_user.display_messages
  end

  def update
    @message = Message.find_by_id(params[:id])
    if @message
      @message.mark_read_by(current_user)
      Pusher.push_readers(@message)
    end 
  end

  private

  def message_params
    params.require(:message).permit(:content)
  end
end

