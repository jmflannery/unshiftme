class AttachmentsController < ApplicationController
  before_filter :authenticate   
   
  def create
    @attachment = current_user.attachments.build(params[:attachment])
    respond_to do |format|
      if @attachment.save
        format.js do
          @attachment.set_recievers
          p @attachment.payload_file_name
          @message = current_user.messages.build(content: @attachment.payload_file_name, attachment_id: @attachment.id)
          if @message.save
            p "saved"
            @message.set_recievers
          else
           p "un-saved" 
          end
        end
      else
        render(action: :get)
      end
    end
  end
end
