class RecipientsController < ApplicationController
  before_filter :authenticate

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
      @recipient = current_user.recipients.find_by_id(params[:id])
      if @recipient
        @recipient.destroy
      else
        redirect_to root_path
      end
    end
  end
end
