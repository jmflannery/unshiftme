class SessionsController < ApplicationController
  include UsersHelper

  def new
    respond_to do |format| 
      format.html {
        @title = "Sign in"
        @td_desks = Desk.of_type("td")
        @ops_desks = Desk.of_type("ops")
      }
      format.json { 
        user = User.find_by_user_name(params[:user])
        normal_desks = ""
        if user and user.normal_desks
          user.normal_desks.each { |desk| normal_desks += "#{desk}," }
        end
        normal_desks.chomp!(",") unless normal_desks.blank?
        render json: { normal_desks: normal_desks }
      }
    end
  end

  def create
    user = User.find_by_user_name(params[:user_name])
    if user && user.authenticate(params[:password])
      user.start_jobs(parse_params_for_desks(params))
      sign_in user

      data = { name: user.user_name, desks: user.desk_names_str }
      send_user_in_or_out_message(data)

      redirect_to user
    else
      flash.now[:error] = "Invalid name and/or password"
      @title = "Sign in"
      redirect_to new_session_path
    end
  end

  def destroy
    data = { name: "vacant", desks: current_user.desk_names_str }
    send_user_in_or_out_message(data)
    
    sign_out
    redirect_to root_path
  end

  private

end
