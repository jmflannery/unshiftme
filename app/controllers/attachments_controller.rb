class AttachmentsController < ApplicationController
  before_filter :authenticate   
   
  def create
    @attachment = current_user.attachments.build(params[:attachment])
    if @attachment.save
      @attachment.set_recievers
        
      @message = current_user.messages.create(content: @attachment.payload_file_name, attachment_id: @attachment.id)
      @message.set_recievers 
      @message.view_class = "message #{@message.id} owner"

      current_user.recipients.each do |recipient|
        if User.exists?(recipient.recipient_user_id)
          recip_user = User.find(recipient.recipient_user_id)
          recip_user.add_recipient(current_user.id) 
        
          data = { sender: current_user.name, 
                   chat_message: @message.content,
                   timestamp: @message.created_at.strftime("%H:%M:%S"),
                   attachment_url: @attachment.payload.url 
          }

          PrivatePub.publish_to("/messages/#{recip_user.name}", data)
        end
      end
    end
  end  
end
