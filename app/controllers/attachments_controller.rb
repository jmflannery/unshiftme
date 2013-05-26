class AttachmentsController < ApplicationController
  before_filter :authenticate   
   
  def create
    @user = current_user
    @message = current_user.create_attached_message(params[:attachment])#.attachments.build(params[:attachment]
    #@attachment = @message.attachment
    if @message and @message.attachment
      #@message = @user.messages.create(content: @attachment.payload_identifier)
      #@message.attach(@attachment)
      @message.generate_outgoing_receipt
      @message.generate_incoming_receipts(attachment: @message.attachment)
      Pusher.push_message(@message)
    end
  end  
end

