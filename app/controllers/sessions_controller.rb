class SessionsController < ApplicationController
  def new
    @title = "Sign in"
  end

  def create
    #user = User.authenticate(params[:session][:name],params[:session][:password])
    #if user.nil?
    #  flash.now[:error] = "Invalid name and/or password"
    #  @title = "Sign in"
    #  render 'new'
    #else
    #  sign_in user
    #  redirect_back_or user
    #end
    user = User.find_by_name(params[:name])
    if user && user.authenticate(params[:password])
      sign_in user
      #redirect_to user
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

