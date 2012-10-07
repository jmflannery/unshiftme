class AttachmentsController < ApplicationController
  before_filter :authenticate   
   
  def create
    @user = current_user
    @attachment = @user.attachments.build(params[:attachment])
    if @attachment.save
      @attachment.set_recievers
        
      @message = @user.messages.create(content: @attachment.payload_file_name, attachment_id: @attachment.id)
      if @message.save
        @message.set_receivers 
        @message.set_sender_workstations
        @message.view_class = "message #{@message.id} owner"
        @message.broadcast
      end
    end
  end  
end

