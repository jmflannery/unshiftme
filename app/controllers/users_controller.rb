class UsersController < ApplicationController
  include UsersHelper

  before_filter :authenticate, only: [:show, :index, :edit, :update, :destroy, :edit_password, :update_password, :heartbeat, :promote]
  before_filter :correct_user, only: [:show, :edit, :update, :edit_password, :update_password]
  before_filter :merge_workstation_parameters, only: [:create, :update]
  before_filter :authenticate_old_password, only: [:update_password]

  def new
    @user = User.new
    @handle = "Register"
    @title = "Register"
    @td_workstations = Workstation.of_type("td")
    @ops_workstations = Workstation.of_type("ops")
  end

  def create
    @user = User.new(params[:user])
    if @user.save
      flash[:success] = "Registration of #{@user.user_name} was successful!"
      redirect_to users_path
    else
      @td_workstations = Workstation.of_type("td")
      @ops_workstations = Workstation.of_type("ops")
      @title = "Register"
      @handle = "Register"
      render 'new'
    end
  end

  def show
    respond_to do |format|
      format.html {
        @handle = @user.handle
        @title = "Messages for #{@user.handle}"
        @message = Message.new
        @attachment = Attachment.new
      }
      format.json {
        user = User.find_by_user_name(params[:id])
        render json: user
      }
    end
  end

  def index
    @handle = current_user.handle
    @title = "Manage Users"
    @users = User.all
  end

  def edit
    @handle = current_user.handle
    @title = "Edit #{current_user.user_name}'s Profile"
    @td_workstations = Workstation.of_type("td")
    @ops_workstations = Workstation.of_type("ops")
  end

  def update
    if @user.update(params[:user])
      flash[:success] = "Profile updated!"
      redirect_to @user
    else
      redirect_to edit_user_path(current_user)
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
    @handle = current_user.handle
    @title = "Change #{current_user.user_name}'s password"
  end

  def update_password
    @user.updating_password!
    if @user.update_attributes(remove_current_password_key_from_hash(params[:user]))
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

  def authenticate_old_password
    unless @user.authenticate(params[:user][:current_password])
      flash[:error] = "Password update failed."
      render :edit_password
    end
  end
end
