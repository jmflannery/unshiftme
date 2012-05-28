class MessagesController < ApplicationController
  before_filter :authenticate
  
  def create
    @user = current_user
    @message = @user.messages.build(params[:message])
    if @message.save
      @message.view_class = "message #{@message.id} owner"
      @message.set_recievers
      @user.recipients.each do |recipient|
        desk = Desk.find(recipient.desk_id)
        if User.exists?(desk.user_id)
          recip_user = User.find(desk.user_id) 
          @user.desks.each { |desk_id| recip_user.add_recipient(Desk.find(desk_id)) }
          
          data = { 
            sender: @user.user_name, 
            chat_message: @message.content,
            from_desks: @user.desk_names_str,
            recipient_id: recipient.id,
            timestamp: @message.created_at.strftime("%a %b %e %Y %T"),
            view_class: "message #{@message.id.to_s} recieved unread"
          }
          PrivatePub.publish_to("/messages/#{recip_user.user_name}", data)
        end
      end
      @message.set_sent_by
    else
      redirect_to new_session_path
    end
  end
  
  def update
    if Message.exists?(params[:id])
      @message = Message.find(params[:id])
      @message.mark_read_by(current_user)

      data = {
        readers: @message.readers,
        message: @message.id
      }  
      message_owner = User.find(@message.user_id)
      PrivatePub.publish_to("/readers/#{message_owner.user_name}", data)
    end 
  end
end
