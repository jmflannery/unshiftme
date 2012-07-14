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

    let!(:cusn) { FactoryGirl.create(:desk, name: "CUS North", abrev: "CUSN", job_type: "td") }
    let!(:cuss) { FactoryGirl.create(:desk, name: "CUS South", abrev: "CUSS", job_type: "td") }

    before(:each) do
      test_sign_in(@admin_user)
    end

    it "returns http success" do
      get :new
      response.should be_success
    end

    it "gets the current user" do
      get :new
      assigns(:user).should == @admin_user
    end

    it "has the right title" do
      get :new
      response.body.should have_selector("title", content: "New Transcript")
    end

    it "gets all desks" do
      get :new
      assigns(:desks).should include cusn.abrev
      assigns(:desks).should include cusn.abrev
    end
  end

  describe "POST 'create'" do
    let(:transcript_user) { FactoryGirl.create(:user) }
    let(:cusn) { FactoryGirl.create(:desk, name: "CUS North", abrev: "CUSN", job_type: "td") }
    let(:transcript_attrs) {{ transcript_user_id: transcript_user.user_name,
                              transcript_desk_id: cusn.abrev,
                              start_time: "2012-04-29 17:52:39",
                              end_time: "2012-04-29 18:30:22"
    }}

    before(:each) do
      test_sign_in(@admin_user)
    end

    it "redirects to the transcript show page" do
      post :create, transcript: transcript_attrs
      response.should redirect_to transcript_path(assigns(:transcript))
    end

    context "with no transcript user or desk id" do
      before { transcript_attrs.merge!({transcript_user_id: "", transcript_desk_id: ""}) }
     
      it "should redirect to the new transcript page" do
        post :create, transcript: transcript_attrs
        response.should redirect_to new_transcript_path
      end

      it "should not create a transcript" do
        lambda do
          post :create, transcript: transcript_attrs
        end.should_not change(Transcript, :count)
      end
    end
  end

  describe "GET 'show'" do

    before(:each) do
      test_sign_in(@admin_user)
      @transcript_user = FactoryGirl.create(:user)
      @transcript = FactoryGirl.create(:transcript, user: @admin_user, transcript_user_id: @transcript_user.id)
    end

    it "returns http success" do
      get 'show', id: @transcript
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
