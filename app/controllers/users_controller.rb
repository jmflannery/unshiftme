class UsersController < ApplicationController
  before_filter :authenticate, :only => [:show, :edit, :update]
  before_filter :correct_user, :only => [:show, :edit, :update]

  def new
    @user = User.new
    @title = "Sign Up"
  end

  def create
    @user = User.new(params[:user])
    if @user.save
      sign_in @user
      redirect_to @user
      #redirect_back_or @user
    else
      @title = "Sign Up"
      render 'new'
      #redirect_to signup_path
    end
  end

  def show
    @user = User.find(params[:id])
    @title = @user.full_name
    @messages = []
    @message = Message.new
    @attachment = Attachment.new
    @my_recipients = Recipient.for_user(@user.id)
  end

  def index
    @online_users = User.available_users(current_user)
  end

  def edit
    @user = User.find(params[:id])
    @title = "Edit user"
  end

  def update
    @user = User.find(params[:id])
    if @user.update_attributes(params[:user])
      flash[:success] = "Profile updated!"
      redirect_to @user
    else
      @title = "Edit user"
      render 'edit'
    end
  end

  private

    def correct_user
      @user = User.find(params[:id])
      redirect_to root_path unless current_user?(@user)
    end
end

