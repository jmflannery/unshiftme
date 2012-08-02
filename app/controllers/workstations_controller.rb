class WorkstationsController < ApplicationController

  def index
    render json: Workstation.all.to_json
  end
end

