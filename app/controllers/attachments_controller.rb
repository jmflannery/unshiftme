class AttachmentsController < ApplicationController
  before_filter :authenticate   
   
  def create
    @attachment = current_user.attachments.build(params[:attachment])
    @recipient_names = ["/messages/#{current_user.name}"]
    current_user.recipients.each do |recipient|
      recip_user = User.find(recipient.recipient_user_id)
      @recipient_names << "/messages/#{recip_user.name}" if recip_user
    end
    
    respond_to do |format|
      if @attachment.save
        format.js do
          @attachment.set_recievers
          @message = current_user.messages.build(content: @attachment.payload_file_name, attachment_id: @attachment.id)
          @message.set_recievers if @message.save
        end
      end
    end
  end
end
