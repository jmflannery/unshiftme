class AttachmentsController < ApplicationController
  before_filter :authenticate   
   
  def create
    @user = current_user
    @attachment = @user.attachments.build(params[:attachment])
    if @attachment.save
      @attachment.set_recievers
        
      @message = @user.messages.create(content: @attachment.payload_identifier, attachment_id: @attachment.id)
      if @message.save
        @message.generate_outgoing_receipt
        @message.generate_incoming_receipts 
        @message.view_class = "message #{@message.id} owner"
        @message.broadcast
      end
    end
  end  
end

