require 'spec_helper'

describe WorkstationsController do

  let!(:cusn) { FactoryGirl.create(:workstation, name: "CUS North", abrev: "CUSN", job_type: "td") }
  let!(:cuss) { FactoryGirl.create(:workstation, name: "CUS South", abrev: "CUSS", job_type: "td") }
  let!(:aml) { FactoryGirl.create(:workstation, name: "AML / NOL", abrev: "AML", job_type: "td") }
  let!(:ydctl) { FactoryGirl.create(:workstation, name: "Yard Control", abrev: "YDCTL", job_type: "ops") }
  let!(:ydmstr) { FactoryGirl.create(:workstation, name: "Yard Master", abrev: "YDMSTR", job_type: "ops") }
  let!(:glhs) { FactoryGirl.create(:workstation, name: "Glasshouse", abrev: "GLHS", job_type: "ops") }

  describe "GET 'index'" do

    it "is returns http success" do
      get :index
      expect(response).to be_success
    end

    it "renders all Workstations as json" do
      json = double('json')
      Workstation.should_receive(:as_json).and_return(json)
      controller.should_receive(:render).with(json: json)
      controller.should_receive(:render)
      get :index
    end
  end 
end
