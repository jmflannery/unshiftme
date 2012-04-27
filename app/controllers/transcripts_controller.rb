class TranscriptsController < ApplicationController
  before_filter :authenticate, only: [:new, :create, :show, :index]
  before_filter :authenticate_admin, only: [:new, :create, :show, :index]
  before_filter :authorized_user, only: [:show]

  def new
    @user = current_user
    @title = "New Transcript"
    @transcript = Transcript.new
    @online_users = User.all.map { |user| [@user.user_name, @user.id] } 
  end

  def create
    puts "hey now #{User.find_by_id(params[:transcript][:watch_user_id]).user_name}"
  end

  def show
  end

  def index
    @title = "Transcripts"
    @user = current_user
    @transcripts = Transcript.for_user(@user)
  end

  private

    def authenticate_admin 
      redirect_to signin_path unless current_user.admin?
    end

    def authorized_user
      @transcript = current_user.transcripts.find_by_id(params[:id])
      redirect_to signin_path if @transcript.nil?
    end
end
