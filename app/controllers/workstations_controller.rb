class WorkstationsController < ApplicationController

  def show
    render json: {"hello" => "i love you"}
  end
end
