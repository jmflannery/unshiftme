class WorkstationsController < ApplicationController

  def index
    render json: Workstation.as_json
  end
end

