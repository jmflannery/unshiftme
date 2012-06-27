class RecipientsController < ApplicationController
  before_filter :authenticate

  def create
    if params[:desk_id] == "all"
      @recipients = current_user.add_recipients(Desk.all)
    else
      desk = Desk.find_by_id(params[:desk_id])
      recipient_user = User.find_by_id(desk.user_id) if desk
      if recipient_user and recipient_user.desks.size > 1
        desks = recipient_user.desks.map { |desk_id| Desk.find(desk_id) }
        @recipients = current_user.add_recipients(desks)
      else
        @recipient = current_user.add_recipient(desk) if desk
      end
    end
  end

  def destroy
    if params[:id] == "all"
      @recipients = current_user.recipients
      current_user.delete_all_recipients
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
