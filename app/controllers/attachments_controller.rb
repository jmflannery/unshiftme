class AttachmentsController < ApplicationController
  before_filter :authenticate   
   
  def create
    @attachment = current_user.attachments.build(params[:attachment])
    respond_to do |format|
      if @attachment.save
        format.js do
          @attachment.set_recievers
           message = current_user.messages.build(content: @attachment.name)
           message.set_recievers if message.save
        end
        #redirect_to current_user
      else
        render(action: :get)
      end
    end
  end
end
