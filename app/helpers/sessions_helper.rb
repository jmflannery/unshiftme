module SessionsHelper
  def sign_in(user)
    session[:user_id] = user.id
    current_user = user
    current_user.set_online
    current_user
  end

  def sign_out
    current_user.delete_all_message_routes
    current_user.set_offline
    session[:user_id] = nil
    current_user = nil 
  end

  def current_user=(user)
    @current_user = user
  end

  def current_user
    @current_user ||= User.find(session[:user_id]) if session[:user_id]
  end

  def signed_in?
    !current_user.nil?
  end
  
  def authenticate
    deny_access unless signed_in?
  end

  def deny_access
   store_location
   redirect_to signin_path, :notice => "Please sign in to access this page."
  end

  def current_user?(user)
    user == current_user
  end

  def redirect_back_or(default)
    redirect_to(session[:return_to] || default)
    clear_return_to
  end

  private

    def send_user_in_or_out_message(data)
      User.online.each do |online_user|
        PrivatePub.publish_to("/workstations/#{online_user.user_name}", data)
      end
    end

    def store_location
      session[:return_to] = request.fullpath
    end

    def clear_return_to
      session[:return_to] = nil
    end
end

