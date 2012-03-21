class RecipientsController < ApplicationController
  before_filter :authenticate
  before_filter :authorized_user, :only => :destroy

  def create
    current_user.add_recipients([params[:user]]) if User.exists?(params[:user])
    
    #user_ids = []
    #params.each do |key,value|
    #  user_ids << value.to_i if key =~ /user_name_.*/
    #end

    #current_user.add_recipients(user_ids)

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
