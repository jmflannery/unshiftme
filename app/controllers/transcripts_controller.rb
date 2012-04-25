class TranscriptsController < ApplicationController
  before_filter :authenticate, :only => [:new, :create, :show, :index]
  before_filter :authenticate_admin, :only => [:new, :create, :show, :index]
  before_filter :authorized_user, :only => [:show, :index]

  def new
    @title = "New Transcript"
  end

  def create
  end

  def show
  end

  def index
    @title = "Transcripts"
  end

  private

    def authenticate_admin 
      @user = User.find(params[:user_id])
      redirect_to signin_path unless @user.admin?
    end

    def authorized_user
      @transcript = current_user.transcripts.find_by_id(params[:id])
      redirect_to signin_path if @transcript.nil?
    end
end
