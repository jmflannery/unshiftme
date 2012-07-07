class UsersController < ApplicationController
  include UsersHelper

  before_filter :authenticate, :only => [:show, :edit, :update]
  before_filter :correct_user, :only => [:show, :edit, :update]

  def new
    @user = User.new
    @title = "Sign Up"
    @td_desks = Desk.of_type("td")
    @ops_desks = Desk.of_type("ops")
  end

  def create
    normal_desks = parse_params_for_desks(params)
    @user = User.new(params[:user])
    @user.normal_desks = normal_desks
    @user.toggle(:admin) if User.count == 0
    if @user.save
      flash[:success] = "Registration was successful! Sign in now to access Messenger."
      redirect_to signin_path
    else
      @title = "Sign Up"
      render 'new'
    end
  end

  def show
    @user = User.find(params[:id])
    @title = @user.handle
    @messages = Message.for_user_before(@user, Time.now)
    @message = Message.new
    @attachment = Attachment.new
    @my_recipients = Recipient.for_user(@user.id)
    @desks = Desk.all
  end

  def edit
    @user = User.find(params[:id])
    @title = "Edit user"
  end

  def update
    @user = User.find(params[:id])
    respond_to do |format|
      format.html {
        if @user.update_attributes(params[:user])
          flash[:success] = "Profile updated!"
          redirect_to @user
        else
          @title = "Edit user"
          render 'edit'
        end
      }
      format.js {
        @user.do_heartbeat
      }
    end
  end

  private

    def correct_user
      @user = User.find(params[:id])
      redirect_to root_path unless current_user?(@user)
    end
end

