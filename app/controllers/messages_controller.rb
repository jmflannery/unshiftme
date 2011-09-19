class MessagesController < ApplicationController
  before_filter :authenticate
  
  def create
    @message = current_user.messages.build(params[:message])
    if @message.save
      redirect_to user_path(current_user)
    else
      render 'pages/about'
    end
  end
  
end
