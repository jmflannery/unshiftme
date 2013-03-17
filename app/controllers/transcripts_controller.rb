class TranscriptsController < ApplicationController
  before_filter :authenticate
  before_filter :authenticate_admin
  before_filter :authorized_user, only: [:show, :destroy]
  before_filter :validate_transcript_attributes, only: [:create]

  def new
    @title = current_user.handle 
    @transcript = Transcript.new
    @users = User.all_user_names.unshift("")
    @workstations = Workstation.all_short_names.unshift("")
  end

  def create
    @transcript = current_user.transcripts.build(@attrs)
    if @transcript.save
      redirect_to transcript_path(@transcript)
    else
      redirect_to new_transcript_path
    end
  end

  def show
    @title = current_user.handle 
    @user = current_user
    respond_to do |format|
      format.html
      format.json {
        render json: @transcript.as_json(user: @transcript.transcript_user)
      }
    end
  end

  def index
    @title = current_user.handle 
    @transcripts = current_user.transcripts
    @transcript_count = current_user.transcripts.size
  end

  def destroy
    @transcript.destroy
    @transcript_count = current_user.transcripts.size
  end

  private

  def authenticate_admin
    redirect_to user_path(current_user) unless current_user.admin?
  end

  def authorized_user
    @transcript = current_user.transcripts.find_by_id(params[:id])
    redirect_to signin_path if @transcript.nil?
  end

  def validate_transcript_attributes
    @attrs = params[:transcript]
    user = User.find_by_user_name(@attrs[:transcript_user_id])
    workstation = Workstation.find_by_abrev(@attrs[:transcript_workstation_id])
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
    unless @attrs[:transcript_user_id] or @attrs[:transcript_workstation_id]
      redirect_to new_transcript_path 
    end
  end
end

