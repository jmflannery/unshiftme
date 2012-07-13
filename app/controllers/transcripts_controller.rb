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
    @user = current_user
    @transcript = @user.transcripts.build(params[:transcript])
    if @transcript.save
      redirect_to transcript_path(@transcript)
    end
  end

  def show
    @user = current_user
    @transcript = Transcript.find(params[:id])
    @watch_user = User.find(@transcript.watch_user_id)
    @start_time = @transcript.start_time.strftime("%a %b %e %Y %T")
    @end_time = @transcript.end_time.strftime("%a %b %e %Y %T")
    @messages = Message.for_user_between(@watch_user, @transcript.start_time, @transcript.end_time)
  end

  def index
    @title = "Transcripts"
    @user = current_user
    #@transcripts = Transcript.for_user(@user)
    @transcripts = @user.transcripts
    @transcript_count = @transcripts ? @transcripts.size : 0
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
