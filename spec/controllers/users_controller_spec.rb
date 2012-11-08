require 'spec_helper'

describe UsersController do
  render_views

  before(:each) do
    @fail_attr = { 
      user_name: "",
      password: "",
      password_confirmation: ""
    }
    
    @success_attr = { 
      user_name: "nxuser",
      password: "foobar",
      password_confirmation: "foobar"
    }
  end

  describe "GET 'new'" do

    it "should be successful" do
      get :new
      response.should be_success
    end

    it "should have the right title" do
      get :new
      response.body.should have_selector("title", :text => "Register")
    end

    it "gets the workstations" do
      td_workstations = stub(Workstation).stub(description: "td")
      ops_workstations = stub(Workstation).stub(description: "ops")
      Workstation.should_receive(:of_type).with("td").and_return(td_workstations)
      Workstation.should_receive(:of_type).with("ops").and_return(ops_workstations)
      get :new
    end
  end

  describe "POST 'create'" do

    describe "failure" do

      it "should not create a user" do
        lambda do
          post :create, :user => @fail_attr
        end.should_not change(User, :count)
      end

      it "should have the right title" do
        post :create, :user => @fail_attr
        response.body.should have_selector("title", :content => "Sign Up")
      end

      it "should render the 'new' page" do
        post :create, :user => @fail_attr
        response.should render_template :new
      end

      it "renders a checkbox for each workstation" do
        workstation = FactoryGirl.create(:workstation, name: "CUS North", abrev: "CUSN", user_id: 0)
        post :create, user: @fail_attr
        response.body.should have_selector("input##{workstation.abrev}")
      end
    end

    describe "success" do

      it "should create a user" do
        lambda do
          post :create, :user => @success_attr
        end.should change(User, :count).by(1)
      end

      it "should not sign the user in" do
        post :create, :user => @success_attr
        controller.should_not be_signed_in
      end

      it "should redirect to the sign in page" do
        post :create, :user => @success_attr
        response.should redirect_to(signin_path)
      end

      it "should display a flash message" do
        post :create, :user => @success_attr
        flash[:success].should eql("Registration was successful! Sign in now to access Messenger.")
      end

      it "should create admin user if it is the first User to be created" do
        post :create, user: @success_attr
        assigns(:user).should be_admin
        post :create, user: @success_attr.merge(user_name: "xuserx")
        assigns(:user).should_not be_admin
      end

      let(:cusn) { FactoryGirl.create(:workstation, name: "CUS North", abrev: "CUSN") }
      let(:aml) { @aml = FactoryGirl.create(:workstation, name: "CUS South", abrev: "CUSS") }
      
      it "sets the user's normal_workstations attribute, given valid parameters" do
        post :create, user: @success_attr, cusn.abrev => "1", aml.abrev => 1
        assigns(:user).normal_workstations.should == ["CUSN", "CUSS"]
      end
    end
  end

  describe "GET 'show'" do

    before(:each) do
      @user = FactoryGirl.create(:user)
      test_sign_in(@user)
    end

    context "format html" do

      it "should be success" do
        get :show, :id => @user
        response.should be_success
      end

      it "should find the right user" do
        get :show, :id => @user
        assigns(:user).should == @user
      end

      it "should have the right title" do
        get :show, :id => @user
        response.body.should have_selector("title", content: @user.user_name)
      end

      it "should include the users name" do
        get :show, :id => @user
        response.should have_selector("p", content: @user.user_name)
      end
      
      it "should create a new attachment (for a subsequent create)" do
        get :show, :id => @user
        assigns(:attachment).should be_kind_of(Attachment) 
      end
    end

    context "format json" do
      
      it "should be success" do
        get :show, id: @user, format: :json
        response.should be_success
      end

      it "should return the correct user id" do
        get :show, id: @user, format: :json
        response.body.should == @user.as_json  
      end
    end
  end
  
  describe "GET 'edit'" do

    before(:each) do
      @user = FactoryGirl.create(:user)
      test_sign_in(@user)
    end

    it "should be successful" do
      get :edit, :id => @user
      response.should be_success
    end

    it "should have the right title" do
      get :edit, :id => @user
      response.body.should have_selector("title", :text => "Edit user")
    end

    it "gets the workstations" do
      td_workstations = stub(Workstation).stub(description: "td")
      ops_workstations = stub(Workstation).stub(description: "ops")
      Workstation.should_receive(:of_type).with("td").and_return(td_workstations)
      Workstation.should_receive(:of_type).with("ops").and_return(ops_workstations)
      get :edit, :id => @user
    end
  end

  describe "PUT 'update'" do

    before(:each) do
      @user = FactoryGirl.create(:user)
      test_sign_in(@user)
    end

    context "format html" do

      describe "failure" do

        it "should render the 'edit' page" do
          put :update, id: @user, user: @fail_attr
          response.should render_template('edit')
        end

        it "should have the right title" do
          put :update, id: @user, user: @fail_attr
          response.body.should have_selector("title", :content => "Edit user")
        end
      end

      describe "success" do

        let(:new_attr) {{
          "user_name" => "fuzbar",
          "password" => "foobar",
          "password_confirmation" => "foobar",
        }}
        let(:params) {{ 
          "id" => @user.user_name,
          "user" => new_attr,
          "CUSN" => "1",
          "AML" => "1",
          "controller" => "users",
          "action" => "update" 
        }}
        let(:normal_workstations) { %w( CUSN AML) }

        before(:each) do
          FactoryGirl.create(:workstation, name: "CUS North", abrev: "CUSN")
          FactoryGirl.create(:workstation, name: "AML / NOL", abrev: "AML")
        end

        it "merges the workstation params into the params[:users] hash" do
          controller.should_receive(:merge_workstation_params).with(params)
          put :update, params
        end

        it "should change the user's attributes" do
          put :update, params
          @user.reload
          @user.user_name.should == new_attr["user_name"]
          @user.normal_workstations.should == normal_workstations
        end

        it "should redirect to the user show page" do
          put :update, params
          @user.reload
          response.should redirect_to(user_path(@user))
        end

        it "should have a flash message" do
          put :update, params
          flash[:success].should =~ /updated/
        end
      end
    end
    
    context "format js" do
  
      it "returns http success" do
        xhr :put, :update, id: @user, format: :js, remote: true
        response.should be_success
      end

      it "updates the authenticated user's heartbeat timestamp" do
        before_request = Time.now
        xhr :put, :update, id: @user, format: :js, remote: true
        @user.reload
        @user.heartbeat.should > before_request
      end
    end
  end

  describe "authentication of show/edit/update pages" do

    before(:each) do
      @user = FactoryGirl.create(:user)
    end

    describe "for non-signed-in users" do

      it "should deny access to 'show'" do
        get :show, id: @user
        response.should redirect_to(signin_path)
      end

      it "should deny access to 'edit'" do
        get :edit, id: @user
        response.should redirect_to(signin_path)
      end

      it "should deny access to 'update'" do
        put :update, id: @user, user: {}
        response.should redirect_to(signin_path)
      end
    end

    describe "for signed-in users" do

      before(:each) do
        wrong_user = FactoryGirl.create(:user)
        test_sign_in(wrong_user)
      end

      it "should require matching user for 'show'" do
        get :show, id: @user
        response.should redirect_to(root_path)
      end

      it "should require matching user for 'edit'" do
        get :edit, id: @user
        response.should redirect_to(root_path)
      end

      it "should require matching user for 'update'" do
        put :update, id: @user, user: {}
        response.should redirect_to(root_path)
      end
    end
  end
end

