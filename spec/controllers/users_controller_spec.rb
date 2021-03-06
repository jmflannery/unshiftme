require 'spec_helper'

describe UsersController do
  render_views

  let!(:user) { FactoryGirl.create(:user, user_name: 'hova', id: 202) }
  let(:success_attr) {{
    "user_name" => "fuzbar",
    "password" => "foobar",
    "password_confirmation" => "foobar",
    "normal_workstations" => %w(CUSN AML)
  }}
  let(:fail_attr) {{
    "user_name" => "",
    "password" => "",
    "password_confirmation" => "",
  }}

  describe "GET 'new'" do

    it "should be successful" do
      get :new
      response.should be_success
    end

    it "assigns the page title to @title" do
      get :new
      expect(assigns(:title)).to eq "Register"
    end

    it "assigns the page title to @handle" do
      get :new
      expect(assigns(:handle)).to eq "Register"
    end

    it "gets the workstations" do
      Workstation.should_receive(:of_type).with("td")
      Workstation.should_receive(:of_type).with("ops")
      get :new
    end
  end

  describe "POST 'create'" do

    describe "failure" do

      let(:params) {{ user: fail_attr }}

      it "should not create a user" do
        lambda do
          post :create, params
        end.should_not change(User, :count)
      end

      it "should have the right title" do
        post :create, params
        response.body.should have_title("Register")
      end

      it "should render the 'new' page" do
        post :create, params
        response.should render_template :new
      end

      it "renders a checkbox for each workstation" do
        workstation = FactoryGirl.create(:workstation, name: "CUS North", abrev: "CUSN", user_id: 0)
        post :create, params
        response.body.should have_selector("input##{workstation.abrev}")
      end
    end

    describe "success" do

      let(:params) {{ user: success_attr }}
      let(:normal_workstations) { %w(CUSN AML) }
      
      it "should create a user" do
        lambda do
          post :create, params
        end.should change(User, :count).by(1)
      end

      it "should not sign the user in" do
        post :create, params
        controller.should_not be_signed_in
      end

      it "should redirect to the sign in page" do
        post :create, params
        response.should redirect_to(users_path)
      end

      it "should display a flash message" do
        post :create, params
        flash[:success].should eql("Registration of #{success_attr["user_name"]} was successful!")
      end

      it "sets the user's normal_workstations attribute, given valid parameters" do
        post :create, params
        assigns(:user).normal_workstations.should == normal_workstations
      end
    end
  end

  describe "GET 'show'" do

    before(:each) do
      test_sign_in(user)
    end

    context "format html" do

      it "should be success" do
        get :show, :id => user
        response.should be_success
      end

      it "should find the right user" do
        get :show, :id => user
        assigns(:user).should == user
      end

      it "assigns the page title to @title" do
        get :show, id: user
        expect(assigns(:title)).to eq "Messages for #{user.handle}"
      end

      it "assigns the user's handle to @handle" do
        get :show, id: user
        expect(assigns(:handle)).to eq user.handle
      end
      
      it "should create a new attachment (for a subsequent create)" do
        get :show, :id => user
        assigns(:attachment).should be_kind_of(Attachment) 
      end
    end

    context "format json" do

      it "should be success" do
        get :show, id: user, format: :json
        response.should be_success
      end

      it "should return the correct user id" do
        get :show, id: user, format: :json
        response.body.should == '{"user":{"id":202,"user_name":"hova","workstations":[],"message_routes":[]}}'
      end
    end
  end

  describe "GET index" do
    
    before(:each) do
      mock_sign_in(user)
    end

    it "finds all of the users" do
      users = double('users')
      User.should_receive(:all).and_return(users)
      controller.should_receive(:render)
      get :index
    end

    it "assigns the page title to @title" do
      get :index
      expect(assigns(:title)).to eq "Manage Users"
    end

    it "assigns the user's handle to @handle" do
      get :index
      expect(assigns(:handle)).to eq user.handle
    end
      
    it "renders the index template" do
      get :index
      response.should render_template(:index)
    end
  end
  
  describe "GET 'edit'" do

    before(:each) do
      test_sign_in(user)
    end

    it "should be successful" do
      get :edit, :id => user
      response.should be_success
    end

    it "assigns the page title to @title" do
      get :edit, id: user
      expect(assigns(:title)).to eq "Edit #{user.user_name}'s Profile"
    end

    it "assigns the user's handle to @handle" do
      get :edit, id: user
      expect(assigns(:handle)).to eq user.handle
    end
      
    it "gets the workstations" do
      td_workstations = double(Workstation).stub(description: "td")
      ops_workstations = double(Workstation).stub(description: "ops")
      Workstation.should_receive(:of_type).with("td").and_return(td_workstations)
      Workstation.should_receive(:of_type).with("ops").and_return(ops_workstations)
      get :edit, :id => user
    end
  end

  describe "PUT 'update'" do

    before(:each) do
      test_sign_in(user)
    end

    describe "failure" do

      it "should redirect back to 'edit' page" do
        put :update, id: user, user: fail_attr
        expect(response).to redirect_to edit_user_path(user)
      end
    end

    describe "success" do

      let(:params) {{ 
        "id" => user.user_name,
        "user" => success_attr
      }}
      let(:normal_workstations) { %w(CUSN AML) }

      it "should change the user's attributes" do
        put :update, params
        user.reload
        user.user_name.should == success_attr["user_name"]
        user.normal_workstations.should == %w(CUSN AML)
      end

      it "should redirect to the user show page" do
        put :update, params
        response.should redirect_to(user_path(user.reload))
      end

      it "should have a flash message" do
        put :update, params
        flash[:success].should =~ /updated/
      end
    end
  end

  describe "DELETE destroy" do
    
    let!(:remove_user) { FactoryGirl.create(:user) }
    let(:params) {{ id: remove_user, format: :js }}
    before(:each) do
      test_sign_in(user)
    end

    context "before confirmation" do

      it "sets confirmed to false" do
        delete :destroy, params
        controller.should_not be_deletion_confirmed
      end
      
      it "renders the users/destroy js template" do
        delete :destroy, params
        response.should render_template("destroy")
      end
    end

    context "cancellation" do

      before(:each) { params.merge!(commit: "Cancel") }

      it "sets deletion_cancelled to true" do
        delete :destroy, params
        controller.should be_deletion_cancelled
      end
      
      it "renders the users/destroy js template" do
        delete :destroy, params
        response.should render_template("destroy")
      end
    end

    context "confirmation" do

      before(:each) { params.merge!(commit: "Yes delete user #{remove_user}") }

      it "sets deletion_confirmed to true" do
        delete :destroy, params
        controller.should be_deletion_confirmed
      end
      
      it "finds and deletes the given user" do
        user = mock_model(User)
        User.should_receive(:find_by_user_name).and_return(user)
        user.should_receive(:destroy)
        delete :destroy, params
      end

      it "renders the users/destroy js template" do
        delete :destroy, params
        response.should render_template("destroy")
      end
    end
  end

  describe "PUT heartbeat" do
    
    before(:each) do
      test_sign_in(user)
    end
    let(:params) {{ id: user.user_name, format: :js, remote: true }}

    it "returns http success" do
      put :heartbeat, params
      response.should be_success
    end

    it "updates the authenticated user's heartbeat timestamp" do
      user.heartbeat = before_request = Time.zone.now
      sleep 1
      put :heartbeat, params
      user.reload.heartbeat.should > before_request
    end
  end

  describe "PUT promote" do
    
    let(:new_admin) { FactoryGirl.create(:user, user_name: "sam", admin: false) }
    let(:params) {{ "id" => new_admin.user_name, "user" => {}, format: :js, remote: true }}
    before(:each) do
      test_sign_in(user)
    end

    it "returns http success" do
      put :promote, params
      response.should be_success
    end

    context "when promoting the user to admin" do

      before { params["user"].merge!("admin" => "1") }

      context "from a non admin user" do

        before { user.update_attribute(:admin, false) }

        it "does not update the user to admin" do
          put :promote, params
          new_admin.reload.should_not be_admin
        end
      end

      context "from an admin user" do

        before { user.update_attribute(:admin, true) }

        it "does update the user to admin" do
          put :promote, params
          new_admin.reload.should be_admin
        end

        it "sets a flash instance variable" do
          put :promote, params
          assigns[:flash].should == "User #{new_admin.user_name} updated to administrator"
        end
      end
    end

    context "when demoting the user to non-admin" do

      before {
        new_admin.update_attribute(:admin, true)
        params["user"].merge!("admin" => "0")
      }

      context "from a non admin user" do
        
        before { user.update_attribute(:admin, false) }

        it "does not update the user to non-admin" do
          put :promote, params
          new_admin.reload.should be_admin
        end
      end

      context "from an admin user" do

        before { user.update_attribute(:admin, true) }

        it "does update the user to non-admin" do
          put :promote, params
          new_admin.reload.should_not be_admin
        end

        it "sets a flash instance variable" do
          put :promote, params
          assigns[:flash].should == "User #{new_admin.user_name} updated to non-administrator"
        end
      end
    end
  end

  describe "GET edit_password" do

    before(:each) do
      test_sign_in(user)
    end
    let(:params) {{ id: user, format: :js }}

    it "should render the edit_password template" do
      get :edit_password, params
      response.should render_template :edit_password
    end

    it "assigns a user variable" do
      get :edit_password, params
      assigns[:user].should == user
    end

    it "assigns the page title to @handle" do
      get :edit_password, params
      expect(assigns(:handle)).to eq user.handle
    end

    it "assigns the page title to @title" do
      get :edit_password, params
      expect(assigns(:title)).to eq "Change #{user.user_name}'s password"
    end
  end

  describe "PUT update_password" do

    before(:each) do
      test_sign_in(user)
    end
    let(:params) {{ id: user, format: :js, user: {} }}

    context "failure" do
     
      let(:user_hash) {{ current_password: "wrongpassword", password: "barfoo", password_confirmation: "barfoo" }}
      before { params[:user].merge!(user_hash) }
      
      it "assignes a flash message" do
        put :update_password, params
        flash[:error].should == "Password update failed."
      end

      it "should render the update_password template" do
        put :update_password, params
        response.should render_template 'edit_password'
      end
    end

    context "success" do
     
      let(:user_hash) {{ "password" => "barfoo", "password_confirmation" => "barfoo" }}
      before do
        params[:user].merge!(user_hash)
        params[:user].merge!("current_password" => "secret")
      end

      it "sets the user to updating password" do
        User.any_instance.should_receive(:updating_password!)
        put :update_password, params
      end
      
      it "assignes a flash message" do
        put :update_password, params
        flash[:success].should == "Password updated!"
      end

      it "updates the user" do
        User.any_instance.should_receive(:update_attributes).with(user_hash)
        put :update_password, params
      end

      it "should redirect to the edit_user_path" do
        put :update_password, params
        response.should redirect_to edit_user_path(user)
      end
    end
  end

  describe "authentication of show/index/edit/update/destroy pages" do

    describe "for non-signed-in users" do

      it "should deny access to 'show'" do
        get :show, id: user
        response.should redirect_to(signin_path)
      end

      it "should deny access to 'edit'" do
        get :edit, id: user
        response.should redirect_to(signin_path)
      end

      it "should deny access to 'update'" do
        put :update, id: user, user: {}
        response.should redirect_to(signin_path)
      end

      it "should deny access to 'index'" do
        get :index
        response.should redirect_to(signin_path)
      end

      it "should deny access to 'destroy'" do
        get :destroy, id: user
        response.should redirect_to(signin_path)
      end
    end

    describe "for signed-in users" do

      before(:each) do
        wrong_user = FactoryGirl.create(:user)
        test_sign_in(wrong_user)
      end

      it "should require matching user for 'show'" do
        get :show, id: user
        response.should redirect_to(root_path)
      end

      it "should require matching user for 'edit'" do
        get :edit, id: user
        response.should redirect_to(root_path)
      end

      it "should require matching user for 'update'" do
        put :update, id: user, user: {}
        response.should redirect_to(root_path)
      end
    end
  end
end
