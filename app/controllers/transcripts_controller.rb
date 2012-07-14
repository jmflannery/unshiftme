class TranscriptsController < ApplicationController
  before_filter :authenticate, only: [:new, :create, :show, :index]
  before_filter :authenticate_admin, only: [:new, :create, :show, :index]
  before_filter :authorized_user, only: [:show]

  def new
    @user = current_user
    @title = "New Transcript"
    @transcript = Transcript.new
    @online_users = User.online.map { |user| user.user_name } 
    @desks = Desk.all.map { |desk| desk.abrev }
  end

  def create
    user = User.find_by_user_name(params[:transcript][:transcript_user_id])
    desk = Desk.find_by_abrev(params[:transcript][:transcript_desk_id])
    #puts "user: #{user.nil?}, desk: #{desk.nil?}"
    transcript_ok = !desk.nil? or !user.nil?
    #puts "ok: #{transcript_ok.to_s}"
    if user
      params[:transcript].merge!({transcript_user_id: user.id})
    else
      params[:transcript].delete(:transcript_user_id)
    end
    if desk
      params[:transcript].merge!({transcript_desk_id: desk.id})
    else
      params[:transcript].delete(:transcript_desk_id)
    end
    @user = current_user
    @transcript = @user.transcripts.build(params[:transcript])
    if transcript_ok and @transcript.save 
      redirect_to transcript_path(@transcript)
    else
      #puts @transcript.errors.inspect
      redirect_to new_transcript_path
    end
  end

  def show
    @user = current_user
    #@transcript = Transcript.find(params[:id])
    @transcript_user = User.find(@transcript.transcript_user_id)
    @start_time = @transcript.start_time.strftime("%a %b %e %Y %T")
    @end_time = @transcript.end_time.strftime("%a %b %e %Y %T")
    @messages = Message.for_user_between(@transcript_user, @transcript.start_time, @transcript.end_time)
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
