require 'spec_helper'

describe WorkstationsController do

  describe "GET 'show' format json" do
    
    it "is returns http success" do
      get :show, format: :json
      response.should be_success
    end
  end 
end

