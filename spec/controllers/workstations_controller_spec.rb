require 'spec_helper'

describe WorkstationsController do

  describe "GET 'index'" do

    it "returns http success" do
      get :index
      expect(response).to be_success
    end

    it "renders all Workstations as json" do
      workstations = double('workstations')
      Workstation.should_receive(:all).and_return(workstations)
      controller.should_receive(:render).with(json: workstations)
      controller.should_receive(:render)
      get :index
    end
  end 
end
