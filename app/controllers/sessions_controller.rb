class SessionsController < ApplicationController
  def new
    @title = "Sign in"
    @td_desks = Desk.of_type("td")
    @ops_desks = Desk.of_type("ops")
  end

  def create
    user = User.find_by_user_name(params[:user_name])
    if user && user.authenticate(params[:password])
      sign_in user
      redirect_back_or user
    else
      flash.now[:error] = "Invalid name and/or password"
      @title = "Sign in"
      render 'new'
    end
  end

  def destroy
    sign_out
    redirect_to root_path
  end
end

