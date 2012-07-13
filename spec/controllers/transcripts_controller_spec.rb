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
      get :new, user: @admin_user.id, format: :js
      response.should be_success
    end
  end

  describe "GET 'create'" do

    before(:each) do
      test_sign_in(@admin_user)
    end

    it "returns http success" do
      post :create, user: @admin_user.id, format: :js
      response.should be_success
    end
  end

  describe "GET 'show'" do

    before(:each) do
      test_sign_in(@admin_user)
      @watch_user = FactoryGirl.create(:user)
      @transcript = FactoryGirl.create(:transcript, user: @admin_user, watch_user_id: @watch_user.id)
    end

    it "returns http success" do
      get 'show', id: @transcript.id
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
