class UsersController < ApplicationController
  include UsersHelper

  before_filter :authenticate, :only => [:show, :edit, :update]
  before_filter :correct_user, :only => [:show, :edit, :update]

  def new
    @user = User.new
    @title = "Sign Up"
    @td_workstations = Workstation.of_type("td")
    @ops_workstations = Workstation.of_type("ops")
  end

  def create
    normal_workstations = parse_params_for_workstations(params)
    @user = User.new(params[:user])
    @user.normal_workstations = normal_workstations
    @user.toggle(:admin) if User.count == 0
    if @user.save
      flash[:success] = "Registration was successful! Sign in now to access Messenger."
      redirect_to signin_path
    else
      @title = "Sign Up"
      @td_workstations = Workstation.of_type("td")
      @ops_workstations = Workstation.of_type("ops")
      @user = User.new
      render 'new'
    end
  end

  def show
    respond_to do |format|
      format.html {
        @title = @user.handle
        @messages = Message.for_user_before(@user, Time.now)
        @messages.each { |message| message.set_view_class(@user) }
        @message = Message.new
        @attachment = Attachment.new
        #@my_recipients = Recipient.for_user(@user.id)
        @workstations = Workstation.all
      }
      format.json {
        user = User.find_by_user_name(params[:id]) if params[:id]
        json = {}
        json[:id] = user.id if user
        render json: json.as_json
      }
    end
  end

  def edit
    @title = "Edit user"
  end

  def update
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
        logger.debug "heartbeat --> <#{@user.user_name} ##{@user.id}>"
        @user.do_heartbeat
      }
    end
  end

  private

    def correct_user
      @user = User.find_by_user_name(params[:id])
      redirect_to root_path unless current_user?(@user)
    end
end

