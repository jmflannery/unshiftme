class RecipientsController < ApplicationController
  before_filter :authenticate
  before_filter :authorized_user, :only => :destroy

  def create
    user_ids = []
    params.each do |k,v|
      user_ids << v if k =~ /user_name_.*/
    end
    
    user_ids.each do |id|
      recip = current_user.recipients.create(:recipient_user_id => id)
    end

    redirect_to recipients_path
  end

  def index
    @my_recipients = Recipient.my_recipients(current_user.id)
  end

  def destroy
    @recipient.destroy
    @my_recipients = Recipient.my_recipients(current_user.id)
  end

  private

    def authorized_user
      @recipient = current_user.recipients.find_by_id(params[:id])
      redirect_to root_path if @recipient.nil?  
    end
end
