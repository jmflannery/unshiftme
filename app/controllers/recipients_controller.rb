class RecipientsController < ApplicationController
  before_filter :authenticate
  before_filter :authorized_user, only: :destroy

  def create
    if params[:desk_id] == "all"
      @desks = current_user.add_recipients(Desk.all)
    else
      @desk = Desk.find_by_id(params[:desk_id])
      @recipient = current_user.add_recipient(@desk) if @desk
    end
  end

  def destroy
    if params[:id] == "all"
      current_user.delete_all_recipients
      current_user.leave_desk
    else
      @recipient.destroy
      @my_recipients = Recipient.for_user(current_user.id)
    end
  end

  private

  def authorized_user
    unless params[:id] == "all"
      @recipient = current_user.recipients.find_by_id(params[:id])
      redirect_to root_path if @recipient.nil?
    end
  end
end
