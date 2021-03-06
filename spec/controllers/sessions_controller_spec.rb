require 'spec_helper'

describe SessionsController do
  render_views

  #let(:cusn) { FactoryGirl.create(:workstation, name: "CUS North", abrev: "CUSN", job_type: "td") }
  #let(:cuss) { FactoryGirl.create(:workstation, name: "CUS South", abrev: "CUSS", job_type: "td") }
  #let(:aml) { FactoryGirl.create(:workstation, name: "AML / NOL", abrev: "AML", job_type: "td") }
  #let(:ydctl) { FactoryGirl.create(:workstation, name: "Yard Control", abrev: "YDCTL", job_type: "ops") }
  #let(:ydmstr) { FactoryGirl.create(:workstation, name: "Yard Master", abrev: "YDMSTR", job_type: "ops") }
  #let(:glhs) { FactoryGirl.create(:workstation, name: "Glasshouse", abrev: "GLHS", job_type: "ops") }

  describe "GET 'new'" do

    describe "format html" do

      it "is successful" do
        get :new, format: :html
        response.should be_success
      end

      it "assigns the page title to @title" do
        get :new, format: :html
        expect(assigns(:title)).to eq "Sign in"
      end

      it "assigns the page title to @handle" do
        get :new, format: :html
        expect(assigns(:handle)).to eq "Sign in"
      end

      it "gets all td and ops workstations" do
        td_workstations = double(Workstation).stub(description: "td")
        ops_workstations = double(Workstation).stub(description: "ops")
        Workstation.should_receive(:of_type).with("td").and_return(td_workstations)
        Workstation.should_receive(:of_type).with("ops").and_return(ops_workstations)
        get :new, format: :html
      end
    end

    describe "format json" do

      it "is successful" do
        get :new, format: :json
        response.should be_success
      end
    end
  end
  
  describe "POST 'create'" do

    describe "invalid signin" do
  
      before(:each) do
        @attr = { user_name: "XXX", password: "invalid" }
      end
  
      it "redirects to the new page" do
        post :create, @attr
        response.should redirect_to new_session_path
      end
  
      it "sets the flash.now message" do
        post :create, @attr
        flash.now[:error].should =~ /invalid/i
      end
    end
  
    describe "with valid email and password" do
  
      let(:cusn) { double('CUSN') }
      let(:cuss) { double('CUSS') }
      let(:user) { FactoryGirl.create(:user) }
      let(:attr) {{ user_name: user.user_name, password: user.password, user: { normal_workstations: %w(CUSN CUSS) } }}

      it "signs the user in" do
        post :create, attr
        expect(controller.current_user).to eq user
        expect(controller).to be_signed_in
      end
  
      it "redirects to the user show page" do
        post :create, attr
        expect(response).to redirect_to(user_path(user))
      end

      it "sets the authenticated user as the user of the given workstations" do
        Workstation.stub(:find_by_abrev).with("CUSN").and_return(cusn)
        Workstation.stub(:find_by_abrev).with("CUSS").and_return(cuss)
        cusn.should_receive(:set_user).with(user)
        cuss.should_receive(:set_user).with(user)
        post :create, attr
      end
  
    end
  end
  
  describe "DELETE 'destroy'" do
  
    it "signs a user out" do
      test_sign_in(FactoryGirl.create(:user))
      delete :destroy
      controller.should_not be_signed_in
      response.should redirect_to(root_path)
    end
  end
end

