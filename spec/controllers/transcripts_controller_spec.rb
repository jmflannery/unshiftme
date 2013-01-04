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

    let(:current_user) { stub('current_user', transcripts: stub('transcripts'), admin?: true) }
    let(:transcript) { stub('transcript', save: nil) }

    before(:each) do
      controller.stub!(:current_user).and_return(current_user)
      User.stub(:find_by_user_name).and_return(stub('transcript_user', id: 1))
    end

    it "builds a transcript" do
      current_user.transcripts.should_receive(:build).and_return(transcript)
      post :create, transcript: {}
    end

    context "save failure" do

      before { transcript.stub(save: false) }

      it "redirects to the new transcript path" do
        current_user.transcripts.stub(:build).and_return(transcript)
        post :create, transcript: {}
        response.should redirect_to new_transcript_path
      end
    end

    context "save success" do

      before { transcript.stub(save: true) }

      it "redirects to the transcript_path(transcript) path" do
        current_user.transcripts.stub(:build).and_return(transcript)
        post :create, transcript: {}
        response.should redirect_to transcript_path(transcript)
      end
    end
  end

  describe "GET 'show'" do

    it "returns http success" do
      user = stub('current_user', admin?: true)
      transcript = stub('transcript', start_time: 'st', end_time: 'et', to_json: 'json', name: 'name')
      user.stub_chain(:transcripts, :find_by_id).and_return(transcript)
      controller.stub!(:current_user).and_return(user)
      transcript.should_receive(:display_messages).with(no_args)
      get :show, id: transcript
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
