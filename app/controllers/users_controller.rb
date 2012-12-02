class UsersController < ApplicationController
  include UsersHelper
  include WorkstationsHelper

  before_filter :authenticate, only: [:show, :index, :edit, :update, :destroy, :edit_password, :update_password, :heartbeat, :promote]
  before_filter :correct_user, only: [:show, :edit, :update, :edit_password, :update_password]
  before_filter :merge_workstation_parameters, only: [:create, :update]
  before_filter :authenticate_old_password, only: [:update_password]

  def new
    @user = User.new
    @title = "Register"
    @td_workstations = Workstation.of_type("td")
    @ops_workstations = Workstation.of_type("ops")
  end

  def create
    @user = User.new(params[:user])
    if @user.save
      flash[:success] = "Registration was successful! Sign in now to access Messenger."
      redirect_to signin_path
    else
      @td_workstations = Workstation.of_type("td")
      @ops_workstations = Workstation.of_type("ops")
      @title = "Register"
      render 'new'
    end
  end

  def show
    respond_to do |format|
      format.html {
        @title = @user.handle
        @message = Message.new
        @attachment = Attachment.new
      }
      format.json {
        user = User.find_by_user_name(params[:id]) if params[:id]
        render json: user.as_json
      }
    end
  end

  def index
    @users = User.all
  end

  def edit
    @title = "Edit user"
    @td_workstations = Workstation.of_type("td")
    @ops_workstations = Workstation.of_type("ops")
  end

  def update
    if @user.update_attributes(params[:user])
      flash[:success] = "Profile updated!"
      redirect_to @user
    else
      @title = "Edit user"
      render 'edit'
    end
  end

  def destroy
    @destroyed_user = User.find_by_user_name(params[:id])

    if deletion_confirmed?
      @destroyed_user.destroy
      @flash_message = "User #{@destroyed_user.user_name} has been deleted."
    end
    respond_to do |format|
      format.js
    end
  end

  def edit_password
  end

  def update_password
    @user.updating_password!
    if @user.update_attributes(remove_old_password_key_from_hash(params[:user]))
      flash[:success] = "Password updated!"
      redirect_to edit_user_path(@user)
    else
      flash[:error] = "Password update failed."
      render :edit_password
    end
  end

  def heartbeat
    time = Time.zone.now
    logger.debug "heartbeat --> <#{current_user.user_name} ##{current_user.id} #{time}>"
    current_user.do_heartbeat(time)
  end

  def promote
    @user = User.find_by_user_name(params[:id])
    if @user and current_user.admin?
      if promoting_user_admin_status?
        @user.update_attribute(:admin, true)
        @flash = "User #{@user.user_name} updated to administrator"
      elsif demoting_user_admin_status?
        @user.update_attribute(:admin, false)
        @flash = "User #{@user.user_name} updated to non-administrator"
      end
    end
  end

  private

  def correct_user
    @user = User.find_by_user_name(params[:id])
    redirect_to root_path unless current_user?(@user)
  end

  def merge_workstation_parameters
    new_params = merge_workstation_params(params)
    params = new_params
  end

  def authenticate_old_password
    unless @user.authenticate(params[:user][:old_password])
      flash[:error] = "Password update failed."
      render :edit_password
    end
  end
end

