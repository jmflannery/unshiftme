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

      data = { name: user.user_name, desks: user.desk_names_str }
      send_user_in_or_out_message(data)

      redirect_back_or user
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
