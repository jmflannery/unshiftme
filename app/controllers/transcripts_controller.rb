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
    @transcript = current_user.transcripts.build(@attrs)
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
    @attrs = params[:transcript]
    user = User.find_by_user_name(@attrs[:transcript_user_id]) if @attrs[:transcript_user_id]
    workstation = Workstation.find_by_abrev(@attrs[:transcript_workstation_id]) if @attrs[:transcript_workstation_id]
    if user
      @attrs.merge!({transcript_user_id: user.id})
    else
      @attrs.delete(:transcript_user_id)
    end
    if workstation
      @attrs.merge!({transcript_workstation_id: workstation.id})
    else
      @attrs.delete(:transcript_workstation_id)
    end
    unless user or workstation
      flash[:notice] = "Must choose a User or Workstation"
      redirect_to new_user_transcript_path(current_user)
    end
  end
end

