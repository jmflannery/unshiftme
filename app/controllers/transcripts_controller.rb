class TranscriptsController < ApplicationController
  before_filter :authenticate, :authorize_user
  before_filter :authorize_transcript, only: [:show, :destroy]
  before_filter :authorize_admin
  before_filter :validate_transcript_attributes, only: [:create]

  def new
    @title = "New Transcript"
    @handle = current_user.handle 
    @transcript = Transcript.new
    @users = User.all_user_names.unshift("")
    @workstations = Workstation.all_short_names.unshift("")
  end

  def create
    @transcript = current_user.transcripts.build(transcript_params)
    if @transcript.save
      redirect_to user_transcript_path(current_user, @transcript)
    else
      redirect_to new_user_transcript_path(current_user)
    end
  end

  def show
    respond_to do |format|
      format.html {
        @title = @transcript.name
        @handle = current_user.handle 
      }
      format.json {
        render json: @transcript.as_json(user: @transcript.transcript_user)
      }
    end
  end

  def index
    @handle = current_user.handle
    @title = "#{current_user.user_name}'s Transcripts"
    @transcripts = current_user.transcripts
    @transcript_count = current_user.transcripts.size
  end

  def destroy
    @transcript.destroy
    @transcript_count = current_user.transcripts.size
  end

  private

  def transcript_params
    params.require(:transcript).permit(:transcript_user_id, :start_time, :end_time)
  end

  def authorize_user
    @user = User.find_by_user_name(params[:user_id])
    unless current_user?(@user)
      flash[:notice] = "Not authorized to view this user's transcripts"
      redirect_to user_path(current_user)
    end
  end

  def authorize_transcript
    @transcript = @user.transcripts.find_by_id(params[:id])
    if @transcript.nil?
      flash[:notice] = "Not authorized to view this transcript"
      redirect_to user_path(current_user)
    end
  end

  def authorize_admin
    unless current_user.admin?
      flash[:notice] = "Must be an administrator to access transcripts"
      redirect_to user_path(current_user)
    end
  end

  def validate_transcript_attributes
    user = User.find_by_user_name(params[:transcript][:transcript_user_id])
    if user
      params[:transcript].merge!({transcript_user_id: user.id})
    else
      flash[:notice] = "Must choose a User"
      redirect_to new_user_transcript_path(current_user)
    end
  end
end

