class SessionsController < ApplicationController
  def new
    @title = "Sign in"
    @td_desks = Desk.of_type("td")
    @ops_desks = Desk.of_type("ops")
  end

  def create
    user = User.find_by_user_name(params[:user_name])
    if user && user.authenticate(params[:password])
      desk_ok = user.authenticate_desk(params)
      sign_in user

      desks = ""
      user.desk_names.each_with_index do |desk_name, i|
        desks += "," unless i == 0
        desks += desk_name
      end

      data = {
        name: user.user_name,
        desks: desks
      }

      User.online.each do |online_user|
        PrivatePub.publish_to("/desks/#{online_user.user_name}", data)
      end

      redirect_back_or user
    else
      flash.now[:error] = "Invalid name and/or password"
      @title = "Sign in"
      redirect_to new_session_path
    end
  end

  def destroy
    sign_out
    redirect_to root_path
  end
end

