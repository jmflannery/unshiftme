class SessionsController < ApplicationController
  include WorkstationsHelper

  def new
    respond_to do |format| 
      format.html {
        @handle = "Sign in"
        @title = "Sign in"
        @td_workstations = Workstation.of_type("td")
        @ops_workstations = Workstation.of_type("ops")
      }
      format.json {
        user = User.find_by_user_name(params[:user])
        normal_workstations = ""
        if user and user.normal_workstations
          user.normal_workstations.each { |workstation| normal_workstations += "#{workstation}," }
        end
        normal_workstations.chomp!(",") unless normal_workstations.blank?
        render json: { normal_workstations: normal_workstations }
      }
    end
  end

  def create
    user = User.find_by_user_name(params[:user_name])
    if user && user.authenticate(params[:password])
      if params[:user]
        params[:user][:normal_workstations].each do |workstation_abrev|
          workstation = Workstation.find_by_abrev(workstation_abrev)
          workstation.set_user(user) if workstation
        end
      end
      sign_in user

      data = { name: user.user_name, workstations: user.workstation_names_str }
      send_user_in_or_out_message(data)

      redirect_to user
    else
      flash.now[:error] = "Invalid name and/or password"
      redirect_to new_session_path
    end
  end

  def destroy
    data = { name: "vacant", workstations: current_user.workstation_names_str }
    send_user_in_or_out_message(data)
    
    sign_out
    redirect_to root_path
  end
end
