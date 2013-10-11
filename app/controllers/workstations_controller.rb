class WorkstationsController < ApplicationController

  def index
    render json: Workstation.all
  end
end

