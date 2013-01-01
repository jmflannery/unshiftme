require 'spec_helper'

describe TranscriptsController do
  render_views

  before(:each) do
    @admin_user = FactoryGirl.create(:user, admin: true)
    @transcript = FactoryGirl.create(:transcript, user: @admin_user)
  end

  describe "access control" do

    describe "for non-signed in users" do

      it "deny's access to 'new'" do
        get :new, user: @admin_user.id, format: :js
        response.should redirect_to(signin_path)
      end

      it "deny's access to 'create'" do
        post :create, user: @admin_user.id, format: :js
        response.should redirect_to(signin_path)
      end

      it "deny's access to 'show'" do
        get :show, id: @transcript.id, user: @admin_user.id
        response.should redirect_to(signin_path)
      end

      it "deny's access to 'index'" do
        get :index, id: @transcript.id, user: @admin_user.id
        response.should redirect_to(signin_path)
      end
    end

    describe "for non-admin in users" do

      before(:each) do
        @non_admin = test_sign_in(FactoryGirl.create(:user))
        @transcript = FactoryGirl.create(:transcript, user: @non_admin)
      end

      it "deny's access to 'new'" do
        get :new, user: @non_admin.id
        response.should redirect_to(signin_path)
      end

      it "deny's access to 'create'" do
        post :create, user: @non_admin.id
        response.should redirect_to(signin_path)
      end

      it "deny's access to 'show'" do
        get :show, id: @transcript.id, user: @non_admin.id
        response.should redirect_to(signin_path)
      end

      it "deny's access to 'index'" do
        get :index, id: @transcript.id, user: @non_admin.id
        response.should redirect_to(signin_path)
      end
    end

    describe "for unauthorized users" do

      before(:each) do
        test_sign_in(@admin_user)
        @other_user = FactoryGirl.create(:user, admin: true)
        @transcript = FactoryGirl.create(:transcript, user: @other_user)
      end

      it "deny's access to 'show'" do
        get :show, id: @transcript.id, user: @admin_user.id
        response.should redirect_to(signin_path)
      end
    end
  end

  describe "GET 'new'" do

    before(:each) do
      test_sign_in(@admin_user)
    end

    it "returns http success" do
      get :new
      response.should be_success
    end

    it "creates a new Transcript" do
      Transcript.should_receive(:new).and_return(mock_model(Transcript))
      get :new
    end

    it "has the right title" do
      get :new
      response.body.should have_selector("title", content: "New Transcript")
    end

    it "gets all workstations abrevs in an Array with a leading empty string" do
      workstations = stub('workstations').as_null_object
      Workstation.should_receive(:all_short_names).and_return(workstations)
      workstations.should_receive(:unshift).with("")
      get :new
    end

    it "gets all User names in an Array with a leading empty string" do
      get :new
      users = stub('users').as_null_object
      User.should_receive(:all_user_names).and_return(users)
      users.should_receive(:unshift).with("")
      get :new
    end
  end

  describe "POST 'create'" do

    let!(:transcript_user) { FactoryGirl.create(:user) }
    let!(:cusn) { FactoryGirl.create(:workstation, name: "CUS North", abrev: "CUSN", job_type: "td") }
    let(:transcript_attrs) {{ transcript_user_id: transcript_user.user_name,
                              transcript_workstation_id: cusn.abrev,
                              start_time: "2012-04-29 17:52:39",
                              end_time: "2012-04-29 18:30:22"
    }}

    before(:each) do
      test_sign_in(@admin_user)
    end

    context "with no transcript user or workstation id" do
      before { transcript_attrs.merge!({transcript_user_id: "", transcript_workstation_id: ""}) }
     
      it "redirects to the new transcript page" do
        post :create, transcript: transcript_attrs
        response.should redirect_to new_transcript_path
      end

      it "does not create a transcript" do
        lambda do
          post :create, transcript: transcript_attrs
        end.should_not change(Transcript, :count)
      end
    end

    context "with a transcript user and no transcript workstation" do
      before { transcript_attrs.merge!({transcript_workstation_id: ""}) }
     
      it "redirects to the transcript show page" do
        post :create, transcript: transcript_attrs
        response.should redirect_to transcript_path(assigns(:transcript))
      end

      it "creates a transcript" do
        lambda do
          post :create, transcript: transcript_attrs
        end.should change(Transcript, :count).by(1)
      end
    end
    
    context "with a transcript workstation and no transcript user" do
      before { transcript_attrs.merge!({transcript_user_id: ""}) }
     
      it "redirects to the transcript show page" do
        post :create, transcript: transcript_attrs
        response.should redirect_to transcript_path(assigns(:transcript))
      end

      it "creates a transcript" do
        lambda do
          post :create, transcript: transcript_attrs
        end.should change(Transcript, :count).by(1)
      end
    end
    
    context "with a transcript workstation and a transcript user" do
      
      it "redirects to the transcript show page" do
        post :create, transcript: transcript_attrs
        response.should redirect_to transcript_path(assigns(:transcript))
      end

      it "creates a transcript" do
        lambda do
          post :create, transcript: transcript_attrs
        end.should change(Transcript, :count).by(1)
      end
    end
  end

  describe "GET 'show'" do

    before(:each) do
      test_sign_in(@admin_user)
      @transcript_user = FactoryGirl.create(:user)
      @transcript = FactoryGirl.create(:transcript, user: @admin_user, transcript_user: @transcript_user)
    end

    it "returns http success" do
      get :show, id: @transcript
      response.should be_success
    end
  end

  describe "GET 'index'" do

    before(:each) do
      test_sign_in(@admin_user)
      #@transcript = FactoryGirl.create(:transcript, user: @admin_user)
    end

    it "returns http success" do
      get :index
      response.should be_success
    end

    it "has the right title" do
      get :index
      response.body.should have_selector("title", content: "Transcripts")
    end

    it "gets current user's transcripts" do
      get :index
      assigns(:transcripts).should include @transcript
    end

    it "gets a count of the current user's transcripts" do
      get :index
      assigns(:transcript_count).should == 1
    end
  end
end
