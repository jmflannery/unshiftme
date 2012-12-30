class AttachmentsController < ApplicationController
  before_filter :authenticate   
   
  def create
    @user = current_user
    @attachment = @user.attachments.build(params[:attachment])
    if @attachment.save

      @message = @user.messages.create(content: @attachment.payload_identifier)
      if @message.save
        @message.attach(@attachment)
        @message.generate_outgoing_receipt
        @message.generate_incoming_receipts(attachment: @attachment)
        @message.set_view_class(current_user)
        @message.broadcast
      end
    end
  end  
end

