class AttachmentsController < ApplicationController
  before_filter :authenticate   
   
  def create
    @message = current_user.create_attached_message(params[:attachment])
    if @message and @message.attachment
      @message.generate_outgoing_receipt
      @message.generate_incoming_receipts(attachment: @message.attachment)
      Pusher.push_message(@message)
    end
  end  
end

