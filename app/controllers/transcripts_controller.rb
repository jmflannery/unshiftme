class TranscriptsController < ApplicationController
  before_filter :authenticate, only: [:new, :create, :show, :index]
  before_filter :authenticate_admin, only: [:new, :create, :show, :index]
  before_filter :authorized_user, only: [:show]
  before_filter :build_transcript_attributes, only: [:create]

  def new
    @user = current_user
    @title = "New Transcript"
    @transcript = Transcript.new
    @online_users = User.online.map { |user| user.user_name } 
    @desks = Desk.all.map { |desk| desk.abrev }
  end

  def create
    @user = current_user
    @transcript = @user.transcripts.build(@attrs)
    if (@attrs.has_key?(:transcript_desk_id) or @attrs.has_key?(:transcript_user_id)) and @transcript.save
      redirect_to transcript_path(@transcript)
    else
      redirect_to new_transcript_path
    end
  end

  def show
    @user = current_user
    @transcript_user = User.find(@transcript.transcript_user_id)
    @start_time = @transcript.start_time.strftime("%a %b %e %Y %T")
    @end_time = @transcript.end_time.strftime("%a %b %e %Y %T")
    @messages = Message.for_user_between(@transcript_user, @transcript.start_time, @transcript.end_time)
  end

  def index
    @title = "Transcripts"
    @user = current_user
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

    def build_transcript_attributes
      @attrs = params[:transcript]
      user = User.find_by_user_name(@attrs[:transcript_user_id])
      desk = Desk.find_by_abrev(@attrs[:transcript_desk_id])
      if user
        @attrs.merge!({transcript_user_id: user.id})
      else
        @attrs.delete(:transcript_user_id)
      end
      if desk
        @attrs.merge!({transcript_desk_id: desk.id})
      else
        @attrs.delete(:transcript_desk_id)
      end
    end
end
