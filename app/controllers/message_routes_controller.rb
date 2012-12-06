class MessageRoutesController < ApplicationController
  before_filter :authenticate

  def create
    if params[:workstation_id] == "all"
      @recipients = current_user.add_recipients(Workstation.all)
    else
      workstation = Workstation.find_by_id(params[:workstation_id])
      recipient_user = User.find_by_id(workstation.user_id) if workstation
      if recipient_user and recipient_user.workstation_ids.size > 1
        workstations = recipient_user.workstation_ids.map { |workstation_id| Workstation.find(workstation_id) }
        @recipients = current_user.add_recipients(workstations)
      else
        @recipient = current_user.add_recipient(workstation) if workstation
      end
    end
  end

  def destroy
    if params[:id] == "all"
      @recipients = current_user.recipients
      current_user.delete_all_recipients
    else
      recipient = current_user.recipients.find_by_id(params[:id])
      
      if recipient
        @recipients = []
        
        workstation1 = Workstation.find_by_id(recipient.workstation_id)
        recip_user = User.find_by_id(workstation1.user_id) if workstation1
        if recip_user
          @recipients = recip_user.workstation_ids.map { |workstation_id| current_user.recipients.find_by_workstation_id(workstation_id) }
          @recipients.each { |recip| recip.destroy }
        else
          recipient.destroy
          @recipients << recipient
        end
      else
        redirect_to root_path
        flash[:error] = "Internal Server Error. Please log in again."
      end
    end
  end
end
