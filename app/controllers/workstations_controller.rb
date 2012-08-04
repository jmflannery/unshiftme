class WorkstationsController < ApplicationController

  def index
    render json: Workstation.all.as_json(only: [:id, :name, :abrev])
  end
end

