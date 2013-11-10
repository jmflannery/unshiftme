class AttachmentsController < ApplicationController
  before_filter :authenticate, :authorize
   
  def create
    @message = @user.create_attached_message(attachment_params)
    if @message and @message.attachment
      @message.generate_outgoing_receipt
      @message.generate_incoming_receipts
      Pusher.push_message(@message)
    end
  end

  def index
    respond_to do |format|
      format.html {
        @handle = current_user.handle
        @title = "Files for #{@user.handle}"
      }
      format.json {
        render json: Attachment.for_user(@user)
      }
    end
  end

  private

  def attachment_params
    params.require(:attachment).permit(:payload)
  end

  def authorize
    @user = User.find_by_user_name(params[:user_id])
    unless current_user?(@user)
      flash[:notice] = 'Not Authorized'
      redirect_to signin_path
    end
  end
end
