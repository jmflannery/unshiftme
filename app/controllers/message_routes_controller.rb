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
      @message_routes = current_user.message_routes
      current_user.delete_all_message_routes
    else
      message_route = current_user.message_routes.find_by_id(params[:id])
      
      if message_route
        @message_routes = []
        
        if message_route.workstation.user
          @message_routes = message_route.workstation.user.workstation_ids.map { |workstation_id| current_user.message_routes.find_by_workstation_id(workstation_id) }
          @message_routes.each { |message_route| message_route.destroy }
        else
          message_route.destroy
          @message_routes << message_route
        end
      else
        redirect_to root_path
        flash[:error] = "Internal Server Error. Please log in again."
      end
    end
  end
end

