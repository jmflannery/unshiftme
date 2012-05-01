class RecipientsController < ApplicationController
  before_filter :authenticate
  before_filter :authorized_user, :only => :destroy

  def create
    current_user.add_recipient(User.find(params[:user])) if User.exists?(params[:user])
    
    redirect_to recipients_path
  end

  def index
    @my_recipients = Recipient.for_user(current_user.id)
    @online_users = User.available_users(current_user)
  end

  def destroy
    @recipient.destroy
    @my_recipients = Recipient.for_user(current_user.id)
    @online_users = User.available_users(current_user)
  end

  private

    def authorized_user
      @recipient = current_user.recipients.find_by_id(params[:id])
      redirect_to root_path if @recipient.nil?  
    end
end
