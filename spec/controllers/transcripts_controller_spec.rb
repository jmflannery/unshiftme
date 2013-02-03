require 'spec_helper'

describe TranscriptsController do
  render_views

  describe "GET 'new'" do

    context "for unauthenticated users" do

      let(:current_user) { nil }
      before(:each) { controller.stub!(:current_user).and_return(current_user) }

      it "redirects to the sign_in path'" do
        get :new
        response.should redirect_to(signin_path)
      end
    end

    context "for non-admin users" do

      let(:current_user) { stub('current_user', admin?: false) }
      before(:each) { controller.stub!(:current_user).and_return(current_user) }

      it "redirects to the sign_in path'" do
        get :new
        response.should redirect_to(user_path(current_user))
      end
    end

    context "for authenticated admin users" do

      let(:current_user) { stub('current_user', transcripts: stub('transcripts'), admin?: true, handle: 'handle') }
      before(:each) { controller.stub!(:current_user).and_return(current_user) }

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
        users = stub('users').as_null_object
        User.should_receive(:all_user_names).and_return(users)
        users.should_receive(:unshift).with("")
        get :new
      end
    end
  end

  describe "POST 'create'" do

    context "for unauthenticated users" do

      let(:current_user) { nil }
      before(:each) { controller.stub!(:current_user).and_return(current_user) }

      it "redirects to the sign_in path'" do
        post :create, transcript: {}
        response.should redirect_to(signin_path)
      end
    end

    context "for non-admin users" do

      let(:current_user) { stub('current_user', admin?: false) }
      before(:each) { controller.stub!(:current_user).and_return(current_user) }

      it "redirects to the sign_in path'" do
        post :create, transcript: {}
        response.should redirect_to(user_path(current_user))
      end
    end

    context "for authenticated admin users" do

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
  end

  describe "GET 'show'" do

    context "for unauthenticated users" do

      let(:current_user) { nil }
      before(:each) { controller.stub!(:current_user).and_return(current_user) }

      it "redirects to the sign_in path'" do
        get :show, id: 1
        response.should redirect_to(signin_path)
      end
    end

    context "for non-admin users" do

      let(:current_user) { stub('current_user', admin?: false) }
      before(:each) { controller.stub!(:current_user).and_return(current_user) }

      it "redirects to the sign_in path'" do
        get :show, id: 1
        response.should redirect_to(user_path(current_user))
      end
    end

    context "for unauthorized users" do

      let(:current_user) { stub('current_user', transcripts: stub('transcripts'), admin?: true) }

      before do
        current_user.transcripts.stub!(:find_by_id).and_return(nil)
        controller.stub!(:current_user).and_return(current_user)
      end

      it "redirects to the signin_path'" do
        get :show, id: 1
        response.should redirect_to(signin_path)
      end
    end

    context "for authenticated admin users" do

      let(:current_user) { stub('current_user', transcripts: stub('transcripts'), admin?: true, handle: 'handle') }
      let(:transcript) { stub('transcript', as_json: 'json', name: 'name') }

      before do
        current_user.transcripts.stub!(:find_by_id).and_return(transcript)
        controller.stub!(:current_user).and_return(current_user)
      end

      it "renders the transcript as json" do
        json = stub('json')
        transcript.should_receive(:as_json).with(no_args).and_return(json)
        controller.should_receive(:render).with(json: json)
        # not sure why render is called twice
        controller.should_receive(:render).with(no_args)
        get :show, id: 1, format: :json
      end
    end
  end

  describe "GET 'index'" do

    context "for unauthenticated users" do

      let(:current_user) { nil }
      before(:each) { controller.stub!(:current_user).and_return(current_user) }

      it "redirects to the sign_in path'" do
        get :index
        response.should redirect_to(signin_path)
      end
    end

    context "for non-admin users" do

      let(:current_user) { stub('current_user', admin?: false) }
      before(:each) { controller.stub!(:current_user).and_return(current_user) }

      it "redirects to the sign_in path'" do
        get :index
        response.should redirect_to(user_path(current_user))
      end
    end

    context "for authenticated admin users" do

      let(:current_user) { stub('current_user', admin?: true, handle: 'handle') }
      let(:transcripts) { mock_model(Transcript, size: 1, name: 'name') }

      before { controller.stub!(:current_user).and_return(current_user) }

      it "returns http success" do
        current_user.stub(:transcripts).and_return(transcripts)
        get :index
        response.should be_success
      end

      it "has the right title" do
        current_user.stub(:transcripts).and_return(transcripts)
        get :index
        response.body.should have_selector("title", content: "Transcripts")
      end

      it "gets current user's transcripts" do
        current_user.should_receive(:transcripts).and_return(transcripts)
        get :index
      end

      it "gets a count of the current user's transcripts" do
        current_user.stub(:transcripts).and_return(transcripts)
        transcripts.should_receive(:size)
        get :index
      end
    end
  end
end

