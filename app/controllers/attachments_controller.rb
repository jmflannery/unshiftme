class AttachmentsController < ApplicationController
  before_filter :authenticate   
   
  def create
    @attachment = current_user.attachments.build(params[:attachment])
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
